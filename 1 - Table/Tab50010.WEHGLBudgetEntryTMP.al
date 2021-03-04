table 50010 "WEH_G/L Budget Entry_TMP"
{
    Caption = 'G/L Budget Entry_TMP';
    fields
    {
        field(1; "Entry No."; Integer) { Editable = false; }
        field(2; "Budget Name"; Code[10]) { }
        field(3; "G/L Account No."; Code[10]) { }
        field(4; "Start Date"; Date) { }
        field(5; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
        }
        field(6; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            trigger OnValidate()
            var
                AVDimValue: Record "Dimension Value";
            begin
                CLEAR(AVDimValue);
                AVDimValue.SETCURRENTKEY(AVDimValue."Dimension Code", AVDimValue.Code);
                AVDimValue.SETRANGE(AVDimValue."Dimension Code", 'Budget code');
                AVDimValue.SETRANGE(AVDimValue.Code, "Global Dimension 2 Code");
                IF AVDimValue.FINDFIRST THEN BEGIN
                    Description := AVDimValue.Name;
                END;
            end;
        }
        field(7; Amount; Decimal) { }
        field(8; Description; Text[100]) { }
        field(9; "Business Unit Code"; Code[10])
        {
            TableRelation = "Business Unit";
        }
        field(10; "User ID"; Code[50])
        {
            TableRelation = User."User Name";
            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.DisplayUserInformation("User ID");
            end;
        }
        field(11; "Budget Dimension 1 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(1);
            trigger OnValidate()
            begin
                IF ("Budget Dimension 1 Code" = '') OR ("Budget Dimension 1 Code" = xRec."Budget Dimension 1 Code") THEN
                    EXIT;
                IF GLBudgetName.Name <> "Budget Name" THEN
                    GLBudgetName.GET("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 1 Code", "Budget Dimension 1 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 1 Code", "Budget Dimension 1 Code");
            end;

            trigger OnLookup()
            begin
                "Budget Dimension 1 Code" := OnLookupDimCode(DimensionOption::"Budget Dimension 1", "Budget Dimension 1 Code");
            end;
        }
        field(12; "Budget Dimension 2 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(2);
            trigger OnValidate()
            begin
                IF ("Budget Dimension 2 Code" = '') OR ("Budget Dimension 2 Code" = xRec."Budget Dimension 2 Code") THEN
                    EXIT;
                IF GLBudgetName.Name <> "Budget Name" THEN
                    GLBudgetName.GET("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 2 Code", "Budget Dimension 2 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 2 Code", "Budget Dimension 2 Code");
            end;

            trigger OnLookup()
            begin
                "Budget Dimension 2 Code" := OnLookupDimCode(DimensionOption::"Budget Dimension 2", "Budget Dimension 2 Code");
            end;
        }
        field(13; "Budget Dimension 3 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(3);
            trigger OnValidate()
            begin
                IF ("Budget Dimension 3 Code" = '') OR ("Budget Dimension 3 Code" = xRec."Budget Dimension 3 Code") THEN
                    EXIT;
                IF GLBudgetName.Name <> "Budget Name" THEN
                    GLBudgetName.GET("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 3 Code", "Budget Dimension 3 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 3 Code", "Budget Dimension 3 Code");
            end;

            trigger OnLookup()
            begin
                "Budget Dimension 3 Code" := OnLookupDimCode(DimensionOption::"Budget Dimension 3", "Budget Dimension 3 Code");
            end;
        }
        field(14; "Budget Dimension 4 Code"; Code[20])
        {
            CaptionClass = GetCaptionClass(4);
            trigger OnValidate()
            begin
                IF ("Budget Dimension 4 Code" = '') OR ("Budget Dimension 4 Code" = xRec."Budget Dimension 4 Code") THEN
                    EXIT;
                IF GLBudgetName.Name <> "Budget Name" THEN
                    GLBudgetName.GET("Budget Name");
                ValidateDimValue(GLBudgetName."Budget Dimension 4 Code", "Budget Dimension 4 Code");
                UpdateDimensionSetId(GLBudgetName."Budget Dimension 4 Code", "Budget Dimension 4 Code");
            end;

            trigger OnLookup()
            begin
                "Budget Dimension 4 Code" := OnLookupDimCode(DimensionOption::"Budget Dimension 4", "Budget Dimension 4 Code");
            end;
        }
        field(15; "Last Date Modified"; Date) { }
        field(16; "Dimension Set ID"; Integer)
        {
            TableRelation = "Dimension Set Entry";
            trigger OnLookup()
            begin
                ShowDimensions;
            end;
        }
        field(17; "Budget Type"; Enum "WEH_Budget Type")
        {
            Caption = 'Budget Type';
        }
        field(18; "Long Text"; Text[150]) { }
        field(19; "End Date"; Date) { }
        field(20; "Extend Date"; Boolean) { }
        field(21; "Before Extend End Date"; Date) { }
        field(22; Quantity; Decimal) { }
        field(23; "Unit Price"; Decimal) { }
        field(24; AmountJan; Decimal) { }
        field(25; AmountFeb; Decimal) { }
        field(26; AmountMar; Decimal) { }
        field(27; AmountApr; Decimal) { }
        field(28; AmountMay; Decimal) { }
        field(29; AmountJun; Decimal) { }
        field(30; AmountJul; Decimal) { }
        field(31; AmountAug; Decimal) { }
        field(32; AmountSep; Decimal) { }
        field(33; AmountOct; Decimal) { }
        field(34; AmountNov; Decimal) { }
        field(35; AmountDec; Decimal) { }
        field(36; "Ref. Document Type"; Enum "WEH_Ref. Document Type") { }
        field(37; "Ref. Document No."; Code[20]) { }
        field(38; "Ref. Document Line No."; Integer) { }
        field(39; "Cancel Budget"; Boolean)
        {
            trigger OnValidate()
            begin
                IF "Cancel Budget" = TRUE THEN BEGIN
                    IF CONFIRM('Do you want to Cancel Budget Code %1 Cost Center %2 ?', TRUE,
                                              "Global Dimension 2 Code", "Global Dimension 1 Code") THEN BEGIN
                        "Cancel Date" := TODAY;
                        "Cancel Amount" := Amount;
                        "Cancel By" := USERID;
                        Amount := 0;
                        MODIFY;
                    END
                    ELSE
                        ERROR('Cancel Budget Need to Confirm.');
                END
                ELSE BEGIN
                    IF CONFIRM('Do you want to UN-Cancel Budget Code %1 Cost Center %2 ?', TRUE,
                                              "Global Dimension 2 Code", "Global Dimension 1 Code") THEN BEGIN
                        "Cancel Date" := 0D;
                        Amount := "Cancel Amount";
                        "Cancel Amount" := 0;
                        "Cancel By" := '';
                        MODIFY;
                    END
                    ELSE
                        ERROR('Un-Cancel Budget Need to Confirm.');
                END;
            end;
        }
        field(40; "Cancel Date"; Date) { }
        field(41; "Cancel Amount"; Decimal) { }
        field(42; "Cancel By"; Code[10]) { }
        field(43; Remark; Text[100]) { }
        field(44; "Supplement Remark"; Text[60]) { }
    }

    keys
    {
        key(Key1; "Entry No.") { }
        key(Key2; "Budget Name", "G/L Account No.", "Start Date", Amount) { SumIndexFields = Amount; }
        key(Key3; "Budget Name",
        "G/L Account No.",
        "Business Unit Code",
        "Global Dimension 1 Code",
        "Global Dimension 2 Code",
        "Budget Dimension 1 Code",
        "Budget Dimension 2 Code", "Budget Dimension 3 Code", "Budget Dimension 4 Code", "Start Date", Amount)
        {
            SumIndexFields = Amount;
        }
        key(Key4; "Budget Name", "G/L Account No.", Description, "Start Date") { }
        key(Key5; "Start Date", "Budget Name", "Dimension Set ID", Amount)
        {
            SumIndexFields = Amount;
        }
        key(Key6; "Last Date Modified", "Budget Name") { }
        key(Key7; "Budget Name", "G/L Account No.", "Start Date", "Global Dimension 2 Code", "Global Dimension 1 Code") { }
    }
    procedure CheckIfBlocked()
    begin
        IF "Budget Name" = GLBudgetName.Name THEN
            EXIT;
        IF GLBudgetName.Name <> "Budget Name" THEN
            GLBudgetName.GET("Budget Name");
        GLBudgetName.TESTFIELD(Blocked, FALSE);
    end;

    procedure ShowDimensions()
    var
        DimSetEntry: Record "Dimension Set Entry";
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", STRSUBSTNO('%1 %2 %3', "Budget Name", "G/L Account No.", "Entry No."));

        IF OldDimSetID = "Dimension Set ID" THEN
            EXIT;

        GetGLSetup;
        GLBudgetName.GET("Budget Name");

        "Global Dimension 1 Code" := '';
        "Global Dimension 2 Code" := '';
        "Budget Dimension 1 Code" := '';
        "Budget Dimension 2 Code" := '';
        "Budget Dimension 3 Code" := '';
        "Budget Dimension 4 Code" := '';

        IF DimSetEntry.GET("Dimension Set ID", GLSetup."Global Dimension 1 Code") THEN
            "Global Dimension 1 Code" := DimSetEntry."Dimension Value Code";
        IF DimSetEntry.GET("Dimension Set ID", GLSetup."Global Dimension 2 Code") THEN
            "Global Dimension 2 Code" := DimSetEntry."Dimension Value Code";
        IF DimSetEntry.GET("Dimension Set ID", GLBudgetName."Budget Dimension 1 Code") THEN
            "Budget Dimension 1 Code" := DimSetEntry."Dimension Value Code";
        IF DimSetEntry.GET("Dimension Set ID", GLBudgetName."Budget Dimension 2 Code") THEN
            "Budget Dimension 2 Code" := DimSetEntry."Dimension Value Code";
        IF DimSetEntry.GET("Dimension Set ID", GLBudgetName."Budget Dimension 3 Code") THEN
            "Budget Dimension 3 Code" := DimSetEntry."Dimension Value Code";
        IF DimSetEntry.GET("Dimension Set ID", GLBudgetName."Budget Dimension 4 Code") THEN
            "Budget Dimension 4 Code" := DimSetEntry."Dimension Value Code";
    end;

    procedure OnLookupDimCode(DimOption: Enum "WEH_Dimension Option"; DefaultValue: Code[20]): Code[20]
    var
        DimValue: Record "Dimension Value";
        DimValueList: Page "Dimension Value List";
    begin
        IF DimOption IN [DimOption::"Global Dimension 1", DimOption::"Global Dimension 2"] THEN
            GetGLSetup
        ELSE
            IF GLBudgetName.Name <> "Budget Name" THEN
                GLBudgetName.GET("Budget Name");
        CASE DimOption OF
            DimOption::"Global Dimension 1":
                DimValue."Dimension Code" := GLSetup."Global Dimension 1 Code";
            DimOption::"Global Dimension 2":
                DimValue."Dimension Code" := GLSetup."Global Dimension 2 Code";
            DimOption::"Budget Dimension 1":
                DimValue."Dimension Code" := GLBudgetName."Budget Dimension 1 Code";
            DimOption::"Budget Dimension 2":
                DimValue."Dimension Code" := GLBudgetName."Budget Dimension 2 Code";
            DimOption::"Budget Dimension 3":
                DimValue."Dimension Code" := GLBudgetName."Budget Dimension 3 Code";
            DimOption::"Budget Dimension 4":
                DimValue."Dimension Code" := GLBudgetName."Budget Dimension 4 Code";
        END;
        DimValue.SETRANGE("Dimension Code", DimValue."Dimension Code");
        IF DimValue.GET(DimValue."Dimension Code", DefaultValue) THEN;
        DimValueList.SETTABLEVIEW(DimValue);
        DimValueList.SETRECORD(DimValue);
        DimValueList.LOOKUPMODE := TRUE;
        IF DimValueList.RUNMODAL = ACTION::LookupOK THEN BEGIN
            DimValueList.GETRECORD(DimValue);
            EXIT(DimValue.Code);
        END;
        EXIT(DefaultValue);
    end;

    procedure GetGLSetup()
    begin
        IF NOT GLSetupRetrieved THEN BEGIN
            GLSetup.GET;
            GLSetupRetrieved := TRUE;
        END;
    end;

    LOCAL procedure UpdateDimensionSetId(DimCode: Code[20]; DimValueCode: Code[20])
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
    begin
        DimMgt.GetDimensionSet(TempDimSetEntry, "Dimension Set ID");
        UpdateDimSet(TempDimSetEntry, DimCode, DimValueCode);
        "Dimension Set ID" := DimMgt.GetDimensionSetID(TempDimSetEntry);
    end;

    procedure UpdateDimSet(VAR TempDimSetEntry: Record "Dimension Set Entry" TEMPORARY; DimCode: Code[20]; DimValueCode: Code[20])
    begin
        IF DimCode = '' THEN
            EXIT;
        IF TempDimSetEntry.GET("Dimension Set ID", DimCode) THEN
            TempDimSetEntry.DELETE;
        IF DimValueCode <> '' THEN BEGIN
            DimVal.GET(DimCode, DimValueCode);
            TempDimSetEntry.INIT;
            TempDimSetEntry."Dimension Set ID" := "Dimension Set ID";
            TempDimSetEntry."Dimension Code" := DimCode;
            TempDimSetEntry."Dimension Value Code" := DimValueCode;
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        END;
    end;

    LOCAL procedure ValidateDimValue(DimCode: Code[20]; VAR DimValueCode: Code[20]): Boolean
    var
        DimValue: Record "Dimension Value";
    begin
        DimValue."Dimension Code" := DimCode;
        DimValue.Code := DimValueCode;
        DimValue.FIND('=><');
        IF DimValueCode <> COPYSTR(DimValue.Code, 1, STRLEN(DimValueCode)) THEN
            ERROR(Text000, DimValueCode, DimCode);
        DimValueCode := DimValue.Code;
    end;

    procedure LastEntryNo(): Integer
    var
        GLBudgetEntry_TMP: Record "WEH_G/L Budget Entry_TMP";
    begin
        GLBudgetEntry_TMP.reset;
        if GLBudgetEntry_TMP.Find('+') then
            exit(GLBudgetEntry_TMP."Entry No." + 1);
        exit(1);
    end;

    procedure GetCaptionClass(BudgetDimType: Integer): Text[250]
    begin
        IF GLBudgetName.Name <> "Budget Name" THEN
            IF NOT GLBudgetName.GET("Budget Name") THEN
                EXIT('');
        CASE BudgetDimType OF
            1:
                BEGIN
                    IF GLBudgetName."Budget Dimension 1 Code" <> '' THEN
                        EXIT('1,5,' + GLBudgetName."Budget Dimension 1 Code");

                    EXIT(Text001);
                END;
            2:
                BEGIN
                    IF GLBudgetName."Budget Dimension 2 Code" <> '' THEN
                        EXIT('1,5,' + GLBudgetName."Budget Dimension 2 Code");

                    EXIT(Text002);
                END;
            3:
                BEGIN
                    IF GLBudgetName."Budget Dimension 3 Code" <> '' THEN
                        EXIT('1,5,' + GLBudgetName."Budget Dimension 3 Code");

                    EXIT(Text003);
                END;
            4:
                BEGIN
                    IF GLBudgetName."Budget Dimension 4 Code" <> '' THEN
                        EXIT('1,5,' + GLBudgetName."Budget Dimension 4 Code");

                    EXIT(Text004);
                END;
        END;
    end;

    var
        GLBudgetName: Record "G/L Budget Name";
        GLSetup: Record "General Ledger Setup";
        DimVal: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        GLSetupRetrieved: Boolean;
        DimensionOption: Enum "WEH_Dimension Option";
        Text000: label 'The dimension value %1 has not been set up for dimension %2.';
        Text001: label '1,5,,Budget Dimension 1 Code';
        Text002: label '1,5,,Budget Dimension 2 Code';
        Text003: label '1,5,,Budget Dimension 3 Code';
        Text004: label '1,5,,Budget Dimension 4 Code';
}