report 50023 "WEH_Available Budget Type C"
{
    DefaultLayout = RDLC;
    RDLCLayout = '8 - Report/Rep50023.WEHAvailableBudgetTypeC.rdl';
    PreviewMode = PrintLayout;
    Caption = 'Available Budget Type C - All';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = ALL;

    dataset
    {
        dataitem("G/L Budget Entry"; "G/L Budget Entry")
        {
            DataItemTableView = sorting("Budget Name", "G/L Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code") WHERE("WEH_Budget Type" = FILTER(C));
            RequestFilterFields = "Budget Name", "Global Dimension 1 Code", "Global Dimension 2 Code";
            column(Budget_Name; "Budget Name") { }
            column(WEH_Budget_Type; "WEH_Budget Type") { }
            column(G_L_Account_No_; "G/L Account No.") { }
            column(Description; Description) { }
            column(Department; "G/L Budget Entry"."Global Dimension 1 Code") { }
            //column(PR_Amount; "G/L Budget Entry"."WEH_Encumbrance PR Amount") { }
            //column(PO_Amount; "G/L Budget Entry"."WEH_Encumbrance PO Amount") { }
            column(Project; "G/L Budget Entry"."Global Dimension 2 Code") { }
            column(PR_Amount; AVPRAmount) { }
            column(PO_Amount; AVPOAmount) { }
            column(AVBudgetAmount; AVBudgetAmount) { }
            column(AVActualAmount; AVActualAmount) { }
            column(AvaliableBudget; AvaliableBudget) { }
            column(CompanyInfoName; CompanyInfo.Name) { }
            column(MasterBudget; AVMasterBudget) { }
            column(AddBudget; AVAddBudget) { }
            column(TransferBudget; AVTransferBudget) { }

            trigger OnPreDataItem()
            begin
                if "G/L Budget Entry".GetFilter("Budget Name") = '' then
                    Error('Please select budget name');
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(AVMasterBudget);
                Clear(AVAddBudget);
                Clear(AVTransferBudget);
                Clear(AVBudgetAmount);
                CLEAR(AVPRAmount);
                CLEAR(AVPOAmount);
                CLEAR(AVActualAmount);
                Clear(AvaliableBudget);

                if AVIncomeBalance <> AVIncomeBalance::" " then begin
                    Clear(AVGLAccountTB);
                    if AVGLAccountTB.Get("G/L Budget Entry"."G/L Account No.") then;
                    if AVIncomeBalance = AVIncomeBalance::"Balance Sheet" then begin
                        if AVGLAccountTB."Income/Balance" <> AVGLAccountTB."Income/Balance"::"Balance Sheet" then
                            CurrReport.Skip();
                    end else
                        if AVIncomeBalance = AVIncomeBalance::"Income Statement" then begin
                            if AVGLAccountTB."Income/Balance" <> AVGLAccountTB."Income/Balance"::"Income Statement" then
                                CurrReport.Skip();
                        end;
                end;

                CompanyInfo.GET;
                //Group Header
                CLEAR(CurrGroup);
                CurrGroup := "Budget Name" + "G/L Account No." + "Global Dimension 1 Code" + "Global Dimension 2 Code";
                IF OldGroup <> CurrGroup THEN BEGIN
                    CLEAR(AVGLSetup);
                    IF AVGLSetup.GET THEN BEGIN
                        AVGLSetup.TESTFIELD("WEH_Active Budget");
                        CLEAR(AVGLBudgetName);
                        AVGLBudgetName.SETCURRENTKEY(Name);
                        AVGLBudgetName.SETRANGE(Name, "Budget Name");
                        IF AVGLBudgetName.FINDFIRST THEN;
                    END;

                    Clear(AVGLBudgetEntry);
                    AVGLBudgetEntry.SetCurrentKey("Entry No.");
                    AVGLBudgetEntry.CopyFilters("G/L Budget Entry");
                    AVGLBudgetEntry.SetRange("WEH_Budget Type", AVGLBudgetEntry."WEH_Budget Type"::C);
                    AVGLBudgetEntry.SetRange("Budget Name", "G/L Budget Entry"."Budget Name");
                    AVGLBudgetEntry.SetRange("G/L Account No.", "G/L Budget Entry"."G/L Account No.");
                    AVGLBudgetEntry.SetRange("Global Dimension 1 Code", "G/L Budget Entry"."Global Dimension 1 Code");
                    AVGLBudgetEntry.SetRange("Global Dimension 2 Code", "G/L Budget Entry"."Global Dimension 2 Code");
                    if AVGLBudgetEntry.Find('-') then
                        repeat
                            if AVGLBudgetEntry."WEH_Add/Transfer Document Type" = AVGLBudgetEntry."WEH_Add/Transfer Document Type"::" " then
                                AVMasterBudget += AVGLBudgetEntry.Amount
                            else
                                if AVGLBudgetEntry."WEH_Add/Transfer Document Type" = AVGLBudgetEntry."WEH_Add/Transfer Document Type"::"Add Budget" then
                                    AVAddBudget += AVGLBudgetEntry.Amount
                                else
                                    if AVGLBudgetEntry."WEH_Add/Transfer Document Type" = AVGLBudgetEntry."WEH_Add/Transfer Document Type"::"Transfer Budget" then
                                        AVTransferBudget += AVGLBudgetEntry.Amount;
                        until AVGLBudgetEntry.Next() = 0;
                    AVBudgetAmount := AVMasterBudget + AVAddBudget + AVTransferBudget;

                    //******* Find Budget Amount *********
                    /*CLEAR(AVGLBudgetEntry);
                    AVGLBudgetEntry.SETCURRENTKEY("Entry No.");
                    AVGLBudgetEntry.SETRANGE("Budget Name", AVGLBudgetName.Name);
                    AVGLBudgetEntry.SETRANGE("G/L Account No.", AVGLSetup."WEH_G/L for Budget Type C");
                    AVGLBudgetEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    AVGLBudgetEntry.SETRANGE("Global Dimension 2 Code", "Global Dimension 2 Code");
                    AVGLBudgetEntry.SETRANGE("WEH_Start Date", AVFromDate, AVToDate);
                    IF AVGLBudgetEntry.FINDSET THEN BEGIN
                        REPEAT
                            AVBudgetAmount := AVBudgetAmount + AVGLBudgetEntry.Amount;
                        UNTIL AVGLBudgetEntry.NEXT = 0;
                    END;*/
                    //******* C-Find Budget Amount *********

                    //******* Find Encumbrance Amount *********
                    Clear(AVGLBudgetEncPRPOTB);
                    AVGLBudgetEncPRPOTB.SetCurrentKey("Entry No.");
                    AVGLBudgetEncPRPOTB.SetRange("Budget Type", AVGLBudgetEncPRPOTB."Budget Type"::C);
                    AVGLBudgetEncPRPOTB.SetRange("Budget Name", AVGLBudgetName."WEH_Encumbrance Name");
                    AVGLBudgetEncPRPOTB.SetRange("No.", "G/L Budget Entry"."G/L Account No.");
                    AVGLBudgetEncPRPOTB.SetRange("Shortcut Dimension 1 Code", "G/L Budget Entry"."Global Dimension 1 Code");
                    AVGLBudgetEncPRPOTB.SetRange("Shortcut Dimension 2 Code", "G/L Budget Entry"."Global Dimension 2 Code");
                    if AVGLBudgetEncPRPOTB.Find('-') then
                        repeat
                            AVPRAmount += AVGLBudgetEncPRPOTB."PR Amount";
                            AVPOAmount += AVGLBudgetEncPRPOTB."PO Amount";
                        until AVGLBudgetEncPRPOTB.Next() = 0;

                    /*CLEAR(AVGLBudgetEntry);
                    AVGLBudgetEntry.SETCURRENTKEY("Entry No.");
                    AVGLBudgetEntry.SETRANGE("Budget Name", AVGLBudgetName."WEH_Encumbrance Name");
                    AVGLBudgetEntry.SETRANGE("G/L Account No.", AVGLSetup."WEH_G/L for Budget Type C");
                    AVGLBudgetEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    AVGLBudgetEntry.SETRANGE("Global Dimension 2 Code", "Global Dimension 2 Code");
                    AVGLBudgetEntry.SETRANGE("WEH_Date filter", AVFromDate, AVToDate);
                    IF AVGLBudgetEntry.FINDSET THEN BEGIN
                        REPEAT
                            AVGLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                            AVPRAmount := AVPRAmount + AVGLBudgetEntry."WEH_Encumbrance PR Amount";
                            AVPOAmount := AVPOAmount + AVGLBudgetEntry."WEH_Encumbrance PO Amount";
                        UNTIL AVGLBudgetEntry.NEXT = 0;
                    END;*/
                    //******* C-Find Encumbrance Amount *********

                    //******* Find Actual Amount *********
                    /*CLEAR(AVGLEntry);
                    AVGLEntry.SETCURRENTKEY("FA Entry Type", "Source Type", "Posting Date", "Global Dimension 2 Code", "Global Dimension 1 Code");
                    AVGLEntry.SETRANGE("FA Entry Type", AVGLEntry."FA Entry Type"::"Fixed Asset");
                    AVGLEntry.SETRANGE("Source Type", AVGLEntry."Source Type"::"Fixed Asset");
                    AVGLEntry.SETRANGE("Posting Date", AVFromDate, AVToDate);
                    AVGLEntry.SETRANGE("Global Dimension 2 Code", '';
                    AVGLEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    AVGLEntry.SETFILTER("Source No.", '<>%1', '');
                    IF AVGLEntry.FINDSET THEN BEGIN
                        REPEAT
                            AVActualAmount := AVActualAmount + AVGLEntry.Amount;
                        UNTIL AVGLEntry.NEXT = 0;
                    END;

                    CLEAR(AVGLEntry);
                    AVGLEntry.SETCURRENTKEY("Global Dimension 1 Code", "Global Dimension 2 Code");
                    AVGLEntry.SETRANGE("Global Dimension 1 Code", "Global Dimension 1 Code");
                    AVGLEntry.SETRANGE("Global Dimension 2 Code", "Global Dimension 2 Code");
                    AVGLEntry.SETFILTER("G/L Account No.", AVGLSetup."WEH_VAT Account");
                    IF AVGLEntry.FINDSET THEN BEGIN
                        REPEAT
                            AVActualAmount := AVActualAmount + AVGLEntry.Amount;
                        UNTIL AVGLEntry.NEXT = 0;
                    END;*/

                    Clear(AVGLEntry);
                    AVGLEntry.SetCurrentKey("Entry No.");
                    AVGLEntry.SetRange("G/L Account No.", "G/L Budget Entry"."G/L Account No.");
                    AVGLEntry.SetRange("Global Dimension 1 Code", "G/L Budget Entry"."Global Dimension 1 Code");
                    AVGLEntry.SetRange("Global Dimension 2 Code", "G/L Budget Entry"."Global Dimension 2 Code");
                    AVGLEntry.CalcSums(Amount);
                    AVActualAmount := AVGLEntry.Amount;
                    //******* C-Find Actual Amount *********

                    CLEAR(AVDimensionValue);
                    AVDimensionValue.SETCURRENTKEY("Dimension Code", Code);
                    AVDimensionValue.SETRANGE("Dimension Code", 'BUDGET CODE');
                    AVDimensionValue.SETRANGE(Code, "Global Dimension 2 Code");
                    IF AVDimensionValue.FINDFIRST THEN;

                    AvaliableBudget := AVBudgetAmount - AVPRAmount - AVPOAmount - AVActualAmount;
                    //Group Header
                END;
                OldGroup := CurrGroup;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group("Filter")
                {
                    field("Income/Balance"; AVIncomeBalance)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }
    var
        LastFieldNo: Integer;
        FooterPrint: Boolean;
        j: Integer;
        RunningNo: Integer;
        CompanyInfo: Record "Company Information";
        AVGLSetup: Record "General Ledger Setup";
        AVGLBudgetName: Record "G/L Budget Name";
        AVGLBudgetName1: Record "G/L Budget Name";
        AVGLEntry: Record "G/L Entry";
        AVBudgetName: Record "G/L Budget Name";
        AVBudgetName1: Record "G/L Budget Name";
        AVYear: Integer;
        Period: Integer;
        Month: Text[30];
        AVMonth_DateFilter: Text[30];
        AVYTD_DateFilter: Text[60];
        AVALLYEAR_DateFilter: Text[60];
        AVFirstDate: Date;
        AVLastDate: Date;
        AVFirstDateText: Text[60];
        AVGLBudgetEntry: Record "G/L Budget Entry";
        AVBudgetAmount: Decimal;
        AVActualAmount: Decimal;
        AVPRAmount: Decimal;
        AVPOAmount: Decimal;
        AVDimensionValue: Record "Dimension Value";
        AVGroupTotal: Decimal;
        AVGrandTotal: Decimal;
        AVGLBudgetShow: Record "G/L Budget Entry";
        AVShowOnlyBudgetandActualNot_0: Boolean;
        AVNotShow: Boolean;
        TxtFilter: Text[1000];
        UseMM_DD_YYYY: Boolean;
        OldGroup: Code[80];
        CurrGroup: Code[80];
        AVFromDate: Date;
        AVToDate: Date;
        AvaliableBudget: Decimal;
        AVMasterBudget: Decimal;
        AVAddBudget: Decimal;
        AVTransferBudget: Decimal;
        AVGLBudgetEncPRPOTB: Record "WEH_G/L Budget Enc. PR/PO";
        AVIncomeBalance: option " ","Income Statement","Balance Sheet";
        AVGLAccountTB: Record "G/L Account";
}