page 50103 "WEH_G/L Budget Entry_TMP"
{
    Caption = 'G/L Budget Entry Temp';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = ALL;
    SourceTable = "WEH_G/L Budget Entry_TMP";
    SourceTableView = SORTING("Entry No.") ORDER(Ascending);
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = 0;
                field("Entry No."; "Entry No.") { ApplicationArea = ALL; }
                field("G/L Account No."; "G/L Account No.") { ApplicationArea = ALL; }
                field(Description; Description) { ApplicationArea = ALL; }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code") { ApplicationArea = ALL; }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code") { ApplicationArea = ALL; }
                field("Budget Dimension 1 Code"; "Budget Dimension 1 Code")
                {
                    ApplicationArea = ALL;
                    Visible = false;
                }
                field("Budget Dimension 2 Code"; "Budget Dimension 2 Code")
                {
                    ApplicationArea = ALL;
                    Visible = false;
                }
                field(AmountJan; AmountJan) { ApplicationArea = ALL; }
                field(AmountFeb; AmountFeb) { ApplicationArea = ALL; }
                field(AmountMar; AmountMar) { ApplicationArea = ALL; }
                field(AmountApr; AmountApr) { ApplicationArea = ALL; }
                field(AmountMay; AmountMay) { ApplicationArea = ALL; }
                field(AmountJun; AmountJun) { ApplicationArea = ALL; }
                field(AmountJul; AmountJul) { ApplicationArea = ALL; }
                field(AmountAug; AmountAug) { ApplicationArea = ALL; }
                field(AmountSep; AmountSep) { ApplicationArea = ALL; }
                field(AmountOct; AmountOct) { ApplicationArea = ALL; }
                field(AmountNov; AmountNov) { ApplicationArea = ALL; }
                field(AmountDec; AmountDec) { ApplicationArea = ALL; }
                field("Budget Type"; "Budget Type") { ApplicationArea = ALL; }
                field("Budget Name"; "Budget Name") { ApplicationArea = ALL; }
                field(Remark; Remark) { ApplicationArea = ALL; }
                field("Budget Dimension 3 Code"; "Budget Dimension 3 Code")
                {
                    ApplicationArea = ALL;
                    Visible = false;
                }
                field("Budget Dimension 4 Code"; "Budget Dimension 4 Code")
                {
                    ApplicationArea = ALL;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            group(Main)
            {
                action("Import Data Budget Entry")
                {
                    ApplicationArea = All;
                    Caption = 'Import Data Budget Entry';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = ImportExcel;

                    trigger OnAction()
                    var
                        GLBudgetTemp: Record "WEH_G/L Budget Entry_TMP";
                        ImportGLBudget: XmlPort "WEH_Import G/L Budget";
                    begin
                        Clear(GLBudgetTemp);
                        if not GLBudgetTemp.IsEmpty then
                            Error('Please clear remaining records before import new ones');

                        Clear(ImportGLBudget);
                        ImportGLBudget.Run;
                    end;
                }
                action("Check and Transfer Data")
                {
                    ApplicationArea = All;
                    Caption = 'Transfer Data';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Image = TransferToLines;

                    trigger OnAction()
                    begin
                        CheckAndTransferBudgetEntry();
                    end;
                }
            }
        }
    }

    local procedure CheckAndTransferBudgetEntry()
    var
        GLBudgetName: Record "G/L Budget Name";
        NewGLBudgetEntry: Record "G/L Budget Entry";
        GLBudgetEntryTmp: Record "WEH_G/L Budget Entry_TMP";
        Window: Dialog;
        SDate: array[12] of Date;
        Year: Integer;
        AllEntry: Integer;
        CountEntry: Integer;
        LastEntryNo: Integer;
    begin
        CLEAR(GLBudgetEntryTmp);
        GLBudgetEntryTmp.SETCURRENTKEY(GLBudgetEntryTmp."Entry No.");
        IF GLBudgetEntryTmp.FINDSET THEN BEGIN
            Window.OPEN('Check And Import Budget ...' + '@1@@@@@@@@@@@@@@@@@@@@@@@@@\');
            ALLEntry := GLBudgetEntryTmp.COUNT;
            REPEAT
                CountEntry := CountEntry + 1;
                Window.UPDATE(1, ROUND(CountEntry / ALLEntry * 10000, 1));

                CLEAR(GLBudgetName);
                GLBudgetName.SETCURRENTKEY(Name);
                GLBudgetName.SETRANGE(Name, GLBudgetEntryTmp."Budget Name");
                IF GLBudgetName.ISEMPTY THEN BEGIN
                    Window.CLOSE;
                    ERROR('Budget Name %1 does not exist.', GLBudgetEntryTmp."Budget Name");
                END;

                IF GLBudgetEntryTmp."G/L Account No." = '' THEN BEGIN
                    Window.CLOSE;
                    ERROR('G/L Account No. must not be blank in entry %1', GLBudgetEntryTmp."Entry No.");
                END;

                IF GLBudgetEntryTmp."Global Dimension 1 Code" = '' THEN BEGIN
                    Window.CLOSE;
                    ERROR('Costcenter Code must not be blank in entry %1', GLBudgetEntryTmp."Entry No.");
                END;

                IF GLBudgetEntryTmp."Budget Name" = '' THEN BEGIN
                    Window.CLOSE;
                    ERROR('Budget Name must not be blank in entry %1', GLBudgetEntryTmp."Entry No.");
                END;

                IF GLBudgetEntryTmp."Budget Type" = GLBudgetEntryTmp."Budget Type"::" " THEN BEGIN
                    Window.CLOSE;
                    ERROR('Budget Type must not be blank in entry %1', GLBudgetEntryTmp."Entry No.");
                END;

                IF COMPANYNAME <> '99_Consolidate' THEN BEGIN
                    IF (GLBudgetEntryTmp."Budget Type" = GLBudgetEntryTmp."Budget Type"::C) AND (GLBudgetEntryTmp."Global Dimension 2 Code" = '') THEN BEGIN
                        Window.CLOSE;
                        ERROR('Budget Code must not be blank in entry %1', GLBudgetEntryTmp."Entry No.");
                    END;
                END ELSE BEGIN
                    IF (GLBudgetEntryTmp."Budget Type" = GLBudgetEntryTmp."Budget Type"::C) AND (GLBudgetEntryTmp."Budget Dimension 4 Code" = '') THEN BEGIN
                        Window.CLOSE;
                        ERROR('Budget Code must not be blank in entry %1', GLBudgetEntryTmp."Entry No.");
                    END;
                END;
                CLEAR(Year);
                CLEAR(SDate);
                CLEAR(GLBudgetName);
                GLBudgetName.SETCURRENTKEY(Name);
                GLBudgetName.SETRANGE(Name, GLBudgetEntryTmp."Budget Name");
                IF GLBudgetName.FINDFIRST THEN BEGIN
                    Year := DATE2DMY(GLBudgetName."WEH_Start Date", 3);

                    SDate[1] := DMY2DATE(1, 1, Year);
                    SDate[2] := DMY2DATE(1, 2, Year);
                    SDate[3] := DMY2DATE(1, 3, Year);
                    SDate[4] := DMY2DATE(1, 4, Year);
                    SDate[5] := DMY2DATE(1, 5, Year);
                    SDate[6] := DMY2DATE(1, 6, Year);
                    SDate[7] := DMY2DATE(1, 7, Year);
                    SDate[8] := DMY2DATE(1, 8, Year);
                    SDate[9] := DMY2DATE(1, 9, Year);
                    SDate[10] := DMY2DATE(1, 10, Year);
                    SDate[11] := DMY2DATE(1, 11, Year);
                    SDate[12] := DMY2DATE(1, 12, Year);
                END;

                IF (GLBudgetEntryTmp.AmountJan <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[1];
                    NewGLBudgetEntry.Date := SDate[1];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountJan;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := GLBudgetEntryTmp.Remark;
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountFeb <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[2];
                    NewGLBudgetEntry.Date := SDate[2];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountFeb;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountMar <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[3];
                    NewGLBudgetEntry.Date := SDate[3];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountMar;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountApr <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[4];
                    NewGLBudgetEntry.Date := SDate[4];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountApr;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountMay <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[5];
                    NewGLBudgetEntry.Date := SDate[5];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountMay;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountJun <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[6];
                    NewGLBudgetEntry.Date := SDate[6];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountJun;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountJul <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[7];
                    NewGLBudgetEntry.Date := SDate[7];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountJul;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountAug <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[8];
                    NewGLBudgetEntry.Date := SDate[8];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountAug;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountSep <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[9];
                    NewGLBudgetEntry.Date := SDate[9];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountSep;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountOct <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[10];
                    NewGLBudgetEntry.Date := SDate[10];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountOct;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountNov <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[11];
                    NewGLBudgetEntry.Date := SDate[11];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountNov;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;

                IF (GLBudgetEntryTmp.AmountDec <> 0) THEN BEGIN
                    CLEAR(LastEntryNo);
                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.SETCURRENTKEY(NewGLBudgetEntry."Entry No.");
                    IF NewGLBudgetEntry.FINDLAST THEN BEGIN
                        LastEntryNo := NewGLBudgetEntry."Entry No.";
                    END;

                    CLEAR(NewGLBudgetEntry);
                    NewGLBudgetEntry.INIT;
                    LastEntryNo := LastEntryNo + 1;
                    NewGLBudgetEntry."Entry No." := LastEntryNo;
                    NewGLBudgetEntry."G/L Account No." := GLBudgetEntryTmp."G/L Account No.";
                    NewGLBudgetEntry.Description := GLBudgetEntryTmp.Description;
                    NewGLBudgetEntry.VALIDATE("Global Dimension 1 Code", GLBudgetEntryTmp."Global Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Global Dimension 2 Code", GLBudgetEntryTmp."Global Dimension 2 Code");
                    NewGLBudgetEntry."WEH_Start Date" := SDate[12];
                    NewGLBudgetEntry.Date := SDate[12];
                    NewGLBudgetEntry.Amount := GLBudgetEntryTmp.AmountDec;
                    NewGLBudgetEntry."WEH_Budget Type" := GLBudgetEntryTmp."Budget Type";
                    NewGLBudgetEntry."Budget Name" := GLBudgetEntryTmp."Budget Name";
                    NewGLBudgetEntry."WEH_G/L Budget Name Type" := NewGLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                    NewGLBudgetEntry."User ID" := USERID;
                    NewGLBudgetEntry.WEH_Remark := 'Import Budget ' + FORMAT(TODAY);
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 1 Code", GLBudgetEntryTmp."Budget Dimension 1 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 2 Code", GLBudgetEntryTmp."Budget Dimension 2 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 3 Code", GLBudgetEntryTmp."Budget Dimension 3 Code");
                    NewGLBudgetEntry.VALIDATE("Budget Dimension 4 Code", GLBudgetEntryTmp."Budget Dimension 4 Code");
                    NewGLBudgetEntry.INSERT(TRUE);
                END;
            UNTIL GLBudgetEntryTmp.NEXT = 0;
            MESSAGE('Import Budget Complete.');
            Window.CLOSE;
            GLBudgetEntryTmp.DELETEALL;
        END;
    end;
}
