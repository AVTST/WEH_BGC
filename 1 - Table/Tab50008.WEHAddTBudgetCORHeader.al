table 50008 "WEH_Add/T. Budget COR Header"
{
    DataClassification = CustomerContent;
    Caption = 'Add/Transfer Budget COR Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            trigger OnValidate()
            begin
                IF "No." <> xRec."No." THEN BEGIN
                    GLSetup.GET;
                    GLSetup.TESTFIELD("WEH_G/L Add Budget Nos.");
                    NoSeriesMgt.TestManual(GLSetup."WEH_G/L Add Budget Nos.");
                    "No. Series" := '';
                END;
            end;
        }
        field(2; "Document Date"; Date)
        {

        }
        field(3; "Posting Date"; Date)
        {

        }
        field(4; "Requested by"; Code[20])
        {
            //TableRelation = Employee."No.";
            TableRelation = "Dimension Value".Code where("Dimension Code" = const('EMPLOYEE'));

            trigger OnValidate()
            var
                //Employee: Record Employee;
                DimValue: Record "Dimension Value";
            begin
                /*
                if "Requested by" <> '' then begin
                    Employee.Get("Requested by");
                    "Requested Name" := Employee."First Name" + ' ' + Employee."Last Name";
                end else
                    "Requested Name" := '';
                */
                if "Requested by" <> '' then begin
                    DimValue.Get('EMPLOYEE', "Requested by");
                    "Requested Name" := DimValue.Name;
                end else
                    "Requested Name" := '';
            end;
        }
        field(5; "Requested Name"; Text[110])
        {

        }
        field(6; Remark; Text[100])
        {

        }
        field(7; "Remark 2"; Text[100])
        {

        }
        field(8; "Created by"; Code[50])
        {

        }
        field(9; "Posted by"; Code[50])
        {

        }
        field(10; Close; Enum "WEH_BGC Close")
        {
            //OptionMembers = " ","CLOSE";
            ObsoleteState = Removed;
        }
        field(11; Status; Enum "WEH_BGC Status")
        {
            //OptionMembers = " ","Posted","Cancel";
        }
        field(12; "No. Series"; Code[10])
        {

        }
        field(13; "Document Type"; Enum "WEH_Add/Transfer Document Type")
        {
            //OptionMembers = " ","Add Budget","Transfer Budget";
        }
        field(14; "Approve Status"; Enum "WEH_BGC Approve Status")
        {
            //OptionMembers = " ","Pending Approval","Approved","Reject";
        }
        field(15; Approve; Boolean)
        {
            ObsoleteState = Removed;
        }
        field(16; "Approved by"; Code[50])
        {

        }
        field(17; "Approved Date"; Date)
        {

        }
        field(18; "Remark 3"; Text[100])
        {

        }
        field(19; "Remark 4"; Text[100])
        {

        }
        field(20; "Remark 5"; Text[100])
        {

        }
        field(21; "Remark 6"; Text[100])
        {

        }
        field(22; "Remark 7"; Text[100])
        {

        }
        field(23; "Remark 8"; Text[100])
        {

        }
        field(24; "Remark 9"; Text[100])
        {

        }
        field(25; "Remark 10"; Text[100])
        {

        }
        field(26; "Post to Budget"; Code[20])
        {
            TableRelation = "G/L Budget Name".Name where("WEH_G/L Budget Name Type" = const("Budget"));
        }
        field(27; "Add Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("WEH_Add/T. Budget COR Line"."Total Amount (LCY)" WHERE("Document No." = FIELD("No.")));
        }

        field(28; "Transfer Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("WEH_Add/T. Budget COR Line"."To Total Amount (LCY)" WHERE("Document No." = FIELD("No.")));
        }
        field(101; "Pending Approvals"; integer)
        {
            Caption = 'Pending Approvals';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Count("Approval Entry" WHERE("Document No." = FIELD("No."),
                                                       Status = FILTER(Open | Created),
                                                       "Table ID" = const(50008)));
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        GLSetup: Record "General Ledger Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        ErrTxt000: Label 'Unexpected error';
        ErrTxt001: Label 'Not allowed to delete approved document';
        ErrTxt002: Label 'Status must not be %1';
        ErrTxt003: Label 'You are not allowed to approve/un-approve/reject budget';
        ErrTxt004: Label 'Line must not be blank';
        ErrTxt005: Label 'Not allowed to delete document';
        ConfTxt000: Label 'Do you want to undo approved Document No. %1?';
        ConfTxt001: Label 'Do you want to send approve request on Document No. %1?';
        ConfTxt002: Label 'Do you want to approve Document No. %1?';
        ConfTxt003: Label 'Do you want to reject approve request on Document No. %1?';
        ConfTxt004: Label 'Do you want to cancel request on Document No. %1?';
        PostConfTxt01: Label 'Do you want to post Document No. %1?';
        PostConfTxt02: Label 'Do you want to post Transfer Budget Cooperate Document No. %1?';
        PostErrTxt01: Label 'Document No. %1 has been posted';
        PostErrTxtRequestBlank: Label 'Request by must not be blank on Document No. %1';
        PostErrTxtApprove: Label 'Document No. %1 must be approved before posting';
        PostErrTxtGLAcc: Label 'G/L Account must be blank on Document No. %1 Line No. %2';
        PostErrTxtDept: Label 'Department must be blank on Document No. %1 Line No. %2';
        PostErrTxtBudgetCode: Label 'Budget Code must be blank on Document No. %1 Line No. %2';
        PostErrTxtGLAccBlank: Label 'G/L Account must not be blank on Document No. %1 Line No. %2';
        PostErrTxtDeptBlank: Label 'Department must not be blank on Document No. %1 Line No. %2';
        PostErrTxtBudgetCodeBlank: Label 'Budget Code must not be blank on Document No. %1 Line No. %2';
        PostErrTxtTotalAmtLCY: Label 'Total Amount (LCY) must not be 0 on Document No. %1 Line No. %2';
        PostErrTxtStartDateBlank: Label 'Start Date must not be blank on Document No. %1 Line No. %2';
        PostErrTxtEndDateBlank: Label 'End Date must not be blank on Document No. %1 Line No. %2';

    trigger OnInsert()
    begin
        GLSetup.GET;
        IF "No." = '' THEN BEGIN
            IF "Document Type" = "Document Type"::"Add Budget" THEN BEGIN
                GLSetup.TESTFIELD(GLSetup."WEH_G/L Add Budget Nos.");
                "No." := NoSeriesMgt.GetNextNo(GLSetup."WEH_G/L Add Budget Nos.", WORKDATE, TRUE);
                "No. Series" := GLSetup."WEH_G/L Add Budget Nos.";
            END
            ELSE BEGIN
                GLSetup.TESTFIELD("WEH_G/L Transfer Budget Nos.");
                "No." := NoSeriesMgt.GetNextNo(GLSetup."WEH_G/L Transfer Budget Nos.", WORKDATE, TRUE);
                "No. Series" := GLSetup."WEH_G/L Transfer Budget Nos.";
            END;
        END;

        "Document Date" := WORKDATE;
        "Posting Date" := WORKDATE;
        "Created by" := USERID;

        "Post to Budget" := GLSetup."WEH_Active Budget";
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        AddBudgetLine: Record "WEH_Add/T. Budget COR Line";
    begin
        Error(ErrTxt005); //28/12/2020

        IF "Approve Status" <> "Approve Status"::" " THEN
            ERROR(ErrTxt001);

        IF Status = Status::Cancel THEN
            ERROR(ErrTxt002, Status);

        CLEAR(AddBudgetLine);
        AddBudgetLine.SETCURRENTKEY("Document No.", "Line No.");
        AddBudgetLine.SETRANGE("Document No.", "No.");
        IF not AddBudgetLine.IsEmpty THEN
            AddBudgetLine.DELETEALL;
    end;

    trigger OnRename()
    begin

    end;

    procedure AssistEdit(OldAddBudgetHead: Record "WEH_Add/T. Budget COR Header"): Boolean
    begin
        GLSetup.GET;
        IF OldAddBudgetHead."Document Type" = OldAddBudgetHead."Document Type"::"Add Budget" THEN BEGIN
            GLSetup.TESTFIELD("WEH_G/L Add Budget Nos.");
            IF NoSeriesMgt.SelectSeries(GLSetup."WEH_G/L Add Budget Nos.", OldAddBudgetHead."No. Series", "No. Series") THEN begin
                NoSeriesMgt.SetSeries("No.");
                EXIT(TRUE);
            end;
        END
        ELSE BEGIN
            GLSetup.TESTFIELD("WEH_G/L Transfer Budget Nos.");
            IF NoSeriesMgt.SelectSeries(GLSetup."WEH_G/L Transfer Budget Nos.", OldAddBudgetHead."No. Series", "No. Series") THEN begin
                NoSeriesMgt.SetSeries("No.");
                EXIT(TRUE);
            end;
        END;
    end;

    /*
    procedure UpdateStatusApprove(StatusIndex: Integer)
    var
        UserSetup: Record "User Setup";
        AddBudgetLine: Record "WEH_Add/T. Budget COR Line";
        ConfTxt: Text;
        StatusOption: Enum "WEH_BGC Approve Status"; //Option " ","Pending Approval","Approved","Reject";
    begin
        if StatusIndex <> 1 then begin
            CLEAR(UserSetup);
            UserSetup.SETCURRENTKEY("User ID");
            UserSetup.SETRANGE("User ID", USERID);
            UserSetup.SETRANGE("WEH_Allow Approve Budget", true);
            IF UserSetup.IsEmpty THEN
                ERROR(ErrTxt003);
        end;

        case StatusIndex of
            0:
                begin
                    TestField("Approve Status", "Approve Status"::Approved);

                    ConfTxt := ConfTxt000;
                    StatusOption := StatusOption::" ";
                end;
            1:
                begin
                    TestField("Approve Status", "Approve Status"::" ");

                    CLEAR(AddBudgetLine);
                    AddBudgetLine.SETCURRENTKEY("Document No.", "Line No.");
                    AddBudgetLine.SETRANGE("Document No.", "No.");
                    AddBudgetLine.SETFILTER("G/L Account No.", '<>%1', '');
                    IF AddBudgetLine.IsEmpty THEN
                        ERROR(ErrTxt004);

                    ConfTxt := ConfTxt001;
                    StatusOption := StatusOption::"Pending Approval";
                end;
            2:
                begin
                    TestField("Approve Status", "Approve Status"::"Pending Approval");

                    ConfTxt := ConfTxt002;
                    StatusOption := StatusOption::Approved;
                end;
            3:
                begin
                    TestField("Approve Status", "Approve Status"::"Pending Approval");

                    ConfTxt := ConfTxt003;
                    StatusOption := StatusOption::Reject;
                end;
            4:
                begin
                    TestField("Approve Status", "Approve Status"::"Pending Approval");

                    ConfTxt := ConfTxt004;
                    StatusOption := StatusOption::" ";
                end;
            else
                Error(ErrTxt000);
        end;

        IF CONFIRM(ConfTxt, TRUE, "No.") THEN BEGIN
            VALIDATE("Approve Status", StatusOption);

            IF "Approve Status" <> "Approve Status"::" " THEN BEGIN
                "Approved by" := USERID;
                "Approved Date" := WORKDATE;
            END ELSE BEGIN
                "Approved by" := '';
                "Approved Date" := 0D;
            END;

            MODIFY;
        END;
    end;
    */

    procedure PosttoGLBudgetEntry(): Boolean
    var
        AddBudgetLine: Record "WEH_Add/T. Budget COR Line";
        GLBudgetEntry: Record "G/L Budget Entry";
        LastEntry: Integer;
    begin
        IF Status = Status::Posted THEN
            ERROR(PostErrTxt01, "No.");

        IF "Requested by" = '' THEN
            ERROR(PostErrTxtRequestBlank, "No.");

        IF "Approve Status" <> "Approve Status"::Approved THEN
            ERROR(PostErrTxtApprove, "No.");

        CLEAR(AddBudgetLine);
        AddBudgetLine.SETCURRENTKEY("Document No.", "Line No.");
        AddBudgetLine.SETRANGE("Document No.", "No.");
        IF AddBudgetLine.FindSet() THEN BEGIN
            REPEAT
                IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::" " THEN BEGIN
                    IF (AddBudgetLine."G/L Account No." <> '') THEN
                        ERROR(PostErrTxtGLAcc, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    IF (AddBudgetLine."Global Dimension 1 Code" <> '') THEN
                        ERROR(PostErrTxtDept, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    IF (AddBudgetLine."Global Dimension 2 Code" <> '') THEN
                        ERROR(PostErrTxtBudgetCode, AddBudgetLine."Document No.", AddBudgetLine."Line No.");
                END ELSE
                    IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::O THEN BEGIN
                        IF (AddBudgetLine."G/L Account No." = '') THEN
                            ERROR(PostErrTxtGLAccBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Global Dimension 1 Code" = '') THEN
                            ERROR(PostErrTxtDeptBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Global Dimension 2 Code" <> '') THEN
                            ERROR(PostErrTxtBudgetCode, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Total Amount (LCY)" = 0) THEN
                            ERROR(PostErrTxtTotalAmtLCY, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Start Date" = 0D) THEN
                            ERROR(PostErrTxtStartDateBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."End Date" = 0D) THEN
                            ERROR(PostErrTxtEndDateBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");
                    END ELSE
                        IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::C THEN BEGIN
                            IF (AddBudgetLine."G/L Account No." = '') THEN
                                ERROR(PostErrTxtGLAccBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Global Dimension 1 Code" = '') THEN
                                ERROR(PostErrTxtDeptBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Global Dimension 2 Code" = '') THEN
                                ERROR(PostErrTxtBudgetCodeBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Total Amount (LCY)" = 0) THEN
                                ERROR(PostErrTxtTotalAmtLCY, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Start Date" = 0D) THEN
                                ERROR(PostErrTxtStartDateBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."End Date" = 0D) THEN
                                ERROR(PostErrTxtEndDateBlank, AddBudgetLine."Document No.", AddBudgetLine."Line No.");
                        END
            UNTIL AddBudgetLine.NEXT() = 0;
        END else
            Error(ErrTxt004);

        IF not CONFIRM(PostConfTxt01, FALSE, "No.") THEn
            EXIT(FALSE);

        CLEAR(GLSetup);
        GLSetup.GET();

        CLEAR(AddBudgetLine);
        AddBudgetLine.SETCURRENTKEY("Document No.");
        AddBudgetLine.SETRANGE("Document No.", "No.");
        IF AddBudgetLine.FindSet() THEN BEGIN
            REPEAT
                CLEAR(LastEntry);
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY(GLBudgetEntry."Entry No.");
                IF GLBudgetEntry.FindLast() THEN
                    LastEntry := GLBudgetEntry."Entry No.";

                CLEAR(GLBudgetEntry);
                GLBudgetEntry.INIT();
                LastEntry := LastEntry + 1;
                GLBudgetEntry."Entry No." := LastEntry;
                GLBudgetEntry."Budget Name" := GLSetup."WEH_Active Budget";
                GLBudgetEntry."WEH_Budget Type" := AddBudgetLine."Budget Type";
                GLBudgetEntry."G/L Account No." := AddBudgetLine."G/L Account No.";
                GLBudgetEntry.VALIDATE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                GLBudgetEntry.VALIDATE("Global Dimension 2 Code", AddBudgetLine."Global Dimension 2 Code");
                GLBudgetEntry.Amount := AddBudgetLine."Total Amount (LCY)";
                GLBudgetEntry.Description := AddBudgetLine.Description;
                GLBudgetEntry."User ID" := USERID;
                GLBudgetEntry."WEH_Long Text" := AddBudgetLine."Long Text";
                GLBudgetEntry.WEH_Remark := AddBudgetLine.Remark;
                GLBudgetEntry."WEH_G/L Budget Name Type" := GLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                GLBudgetEntry."WEH_Add/Transfer Document Type" := Rec."Document Type";
                GLBudgetEntry."WEH_Add/Transfer Document No." := AddBudgetLine."Document No.";
                GLBudgetEntry."WEH_Document Posting Date" := Rec."Posting Date";
                GLBudgetEntry."WEH_Document Date" := Rec."Document Date";
                GLBudgetEntry."Date" := AddBudgetLine."Start Date";
                GLBudgetEntry."WEH_End Date" := AddBudgetLine."End Date";
                GLBudgetEntry."WEH_Start Date" := AddBudgetLine."Start Date";
                GLBudgetEntry.VALIDATE("Budget Dimension 1 Code", AddBudgetLine."Budget Dimension 1 Code");
                GLBudgetEntry.VALIDATE("Budget Dimension 2 Code", AddBudgetLine."Budget Dimension 2 Code");
                GLBudgetEntry.INSERT();
            UNTIL AddBudgetLine.NEXT() = 0;

            "Post to Budget" := GLSetup."WEH_Active Budget";
            Status := Status::Posted;
            "Posted by" := USERID;
            MODIFY();

            EXIT(TRUE);
        END ELSE
            EXIT(FALSE);
    end;

    procedure PostTransferGLBudgetEntry(): Boolean
    var
        AddBudgetLine: Record "WEH_Add/T. Budget COR Line";
        GLBudgetEntry: Record "G/L Budget Entry";
        LastEntry: Integer;
        AvailableCash: Decimal;
    begin
        IF Rec.Status = Rec.Status::Posted THEN
            ERROR('Document No. %1 Already Post.', Rec."No.");

        IF Rec."Requested by" = '' THEN
            ERROR('Document No. %1 Request By must not be Blank.', Rec."No.");

        IF Rec."Approve Status" <> Rec."Approve Status"::Approved THEN
            ERROR('Document No. %1 must Approve before Post.', Rec."No.");

        CLEAR(AddBudgetLine);
        AddBudgetLine.SETCURRENTKEY("Document No.");
        AddBudgetLine.SETRANGE("Document No.", Rec."No.");
        IF AddBudgetLine.FindSet() THEN BEGIN
            REPEAT
                IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::" " THEN BEGIN
                    //Transfer From
                    IF (AddBudgetLine."G/L Account No." <> '') THEN
                        ERROR('Document No. %1 Line No. %2 G/L Account must be Blank.',
                                 AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    IF (AddBudgetLine."Global Dimension 1 Code" <> '') THEN
                        ERROR('Document No. %1 Line No. %2 Department must be Blank.',
                                 AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    IF (AddBudgetLine."Global Dimension 2 Code" <> '') THEN
                        ERROR('Document No. %1 Line No. %2 Budget Code must be Blank.',
                                 AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    //Transfer To
                    IF (AddBudgetLine."To G/L Account No." <> '') THEN
                        ERROR('Document No. %1 Line No. %2 To G/L Account must be Blank.',
                                 AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    IF (AddBudgetLine."To Global Dimension 1 Code" <> '') THEN
                        ERROR('Document No. %1 Line No. %2 To Department must be Blank.',
                                 AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                    IF (AddBudgetLine."To Global Dimension 2 Code" <> '') THEN
                        ERROR('Document No. %1 Line No. %2 To Budget Code must be Blank.',
                                 AddBudgetLine."Document No.", AddBudgetLine."Line No.");
                END ELSE
                    IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::O THEN BEGIN
                        //Transfer From
                        IF (AddBudgetLine."G/L Account No." = '') THEN
                            ERROR('Document No. %1 Line No. %2 G/L Account must not be Blank.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Global Dimension 1 Code" = '') THEN
                            ERROR('Document No. %1 Line No. %2 Department must not be Blank.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Global Dimension 2 Code" <> '') THEN
                            ERROR('Document No. %1 Line No. %2 Budget Code must be Blank.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."To Total Amount (LCY)" = 0) THEN
                            ERROR('Document No. %1 Line No. %2 Total Amount (LCY) must not be 0.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."Start Date" = 0D) THEN
                            ERROR('Document No. %1 Line No. %2 Start Date must not be 0.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."End Date" = 0D) THEN
                            ERROR('Document No. %1 Line No. %2 End Date must not be 0.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        //Transfer To
                        IF (AddBudgetLine."To G/L Account No." = '') THEN
                            ERROR('Document No. %1 Line No. %2 To G/L Account must not be Blank.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."To Global Dimension 1 Code" = '') THEN
                            ERROR('Document No. %1 Line No. %2 To Department must not be Blank.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."To Global Dimension 2 Code" <> '') THEN
                            ERROR('Document No. %1 Line No. %2 To Budget Code must be Blank.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."To Total Amount (LCY)" = 0) THEN
                            ERROR('Document No. %1 Line No. %2 To Total Amount (LCY) must not be 0.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."To Start Date" = 0D) THEN
                            ERROR('Document No. %1 Line No. %2 To Start Date must not be 0.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                        IF (AddBudgetLine."To End Date" = 0D) THEN
                            ERROR('Document No. %1 Line No. %2 To End Date must not be 0.',
                                     AddBudgetLine."Document No.", AddBudgetLine."Line No.");
                    END ELSE
                        IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::C THEN BEGIN
                            //Transfer From
                            IF (AddBudgetLine."G/L Account No." = '') THEN
                                ERROR('Document No. %1 Line No. %2 G/L Account must not be Blank.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Global Dimension 1 Code" = '') THEN
                                ERROR('Document No. %1 Line No. %2 Department must not be Blank.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Global Dimension 2 Code" = '') THEN
                                ERROR('Document No. %1 Line No. %2 Budget Code must not be Blank.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."To Total Amount (LCY)" = 0) THEN
                                ERROR('Document No. %1 Line No. %2 Total Amount (LCY) must not be 0.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."Start Date" = 0D) THEN
                                ERROR('Document No. %1 Line No. %2 Start Date must not be 0.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."End Date" = 0D) THEN
                                ERROR('Document No. %1 Line No. %2 End Date must not be 0.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            //Transfer To
                            IF (AddBudgetLine."To G/L Account No." = '') THEN
                                ERROR('Document No. %1 Line No. %2 To G/L Account must not be Blank.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."To Global Dimension 1 Code" = '') THEN
                                ERROR('Document No. %1 Line No. %2 To Department must not be Blank.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."To Global Dimension 2 Code" = '') THEN
                                ERROR('Document No. %1 Line No. %2 To Budget Code must not be Blank.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."To Total Amount (LCY)" = 0) THEN
                                ERROR('Document No. %1 Line No. %2 To Total Amount (LCY) must not be 0.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."To Start Date" = 0D) THEN
                                ERROR('Document No. %1 Line No. %2 To Start Date must not be 0.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");

                            IF (AddBudgetLine."To End Date" = 0D) THEN
                                ERROR('Document No. %1 Line No. %2 To End Date must not be 0.',
                                         AddBudgetLine."Document No.", AddBudgetLine."Line No.");
                        END
            UNTIL AddBudgetLine.NEXT() = 0;
        END;

        IF not CONFIRM(PostConfTxt02, FALSE, Rec."No.") THEN
            EXIT(FALSE);

        CLEAR(GLSetup);
        GLSetup.GET();

        CLEAR(AddBudgetLine);
        AddBudgetLine.SETCURRENTKEY("Document No.", "Line No.");
        AddBudgetLine.SETRANGE("Document No.", Rec."No.");
        IF AddBudgetLine.FINDSET() THEN BEGIN
            REPEAT
                CLEAR(AvailableCash);
                /* Wait page
                CLEAR(FormCheckAvaiableBudget);
                FormCheckAvaiableBudget.FindBudgetAvaiable(AddBudgetLine."Budget Type", AddBudgetLine."G/L Account No.",
                                                       AddBudgetLine."Global Dimension 1 Code",
                                                       AddBudgetLine."Global Dimension 2 Code");
                AvailableCash := FormCheckAvaiableBudget.ReturnBudgetAmt;

                //IF AddBudgetLine."Budget Type" <> AddBudgetLine."Budget Type"::V THEN
                    IF AddBudgetLine."To Total Amount (LCY)" > AvailableCash THEN
                        ERROR('Document No. %1 Line No. %2 Cannot Transfer because Cash Available = %3, Request Transfer = %4'
                               , AddBudgetLine."Document No.", AddBudgetLine."Line No.",
                                AvailableCash, AddBudgetLine."To Total Amount (LCY)");
                */

                //Transfer From
                CLEAR(LastEntry);
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY("Entry No.");
                IF GLBudgetEntry.FINDLAST THEN
                    LastEntry := GLBudgetEntry."Entry No.";

                LastEntry += 1;
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.INIT();
                GLBudgetEntry."Entry No." := LastEntry;
                GLBudgetEntry."Budget Name" := GLSetup."WEH_Active Budget";
                GLBudgetEntry."WEH_Budget Type" := AddBudgetLine."Budget Type";
                GLBudgetEntry."G/L Account No." := AddBudgetLine."G/L Account No.";
                GLBudgetEntry."Date" := AddBudgetLine."Start Date"; //DMY2DATE(1, DATE2DMY(Rec."Posting Date", 2), DATE2DMY(Rec."Posting Date", 3));
                GLBudgetEntry.VALIDATE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                GLBudgetEntry.VALIDATE("Global Dimension 2 Code", AddBudgetLine."Global Dimension 2 Code");
                GLBudgetEntry.Amount := -AddBudgetLine."To Total Amount (LCY)";
                GLBudgetEntry.Description := AddBudgetLine.Description;
                GLBudgetEntry."User ID" := USERID;
                IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::O THEN
                    GLBudgetEntry."WEH_Long Text" := 'Transfer To G/L No. ' + FORMAT(AddBudgetLine."To G/L Account No.") + ' ' +
                                                     'Department ' + FORMAT(AddBudgetLine."To Global Dimension 1 Code")
                ELSE
                    IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::C THEN
                        GLBudgetEntry."WEH_Long Text" := 'Transfer To Budget Code ' + FORMAT(AddBudgetLine."To Global Dimension 2 Code") + ' ' +
                                                         'Department ' + FORMAT(AddBudgetLine."To Global Dimension 1 Code");

                GLBudgetEntry.WEH_Remark := AddBudgetLine.Remark;
                GLBudgetEntry."WEH_Start Date" := AddBudgetLine."Start Date";
                GLBudgetEntry."WEH_End Date" := AddBudgetLine."End Date";
                GLBudgetEntry."WEH_G/L Budget Name Type" := GLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                GLBudgetEntry."WEH_Add/Transfer Document No." := AddBudgetLine."Document No.";
                GLBudgetEntry."WEH_Document Posting Date" := Rec."Posting Date";
                GLBudgetEntry."WEH_Document Date" := Rec."Document Date";
                GLBudgetEntry.VALIDATE("Budget Dimension 1 Code", AddBudgetLine."Budget Dimension 1 Code");
                GLBudgetEntry.VALIDATE("Budget Dimension 2 Code", AddBudgetLine."Budget Dimension 2 Code");
                GLBudgetEntry.INSERT();

                //Transfer To
                LastEntry += 1;
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.INIT();
                GLBudgetEntry."Entry No." := LastEntry;
                GLBudgetEntry."Budget Name" := GLSetup."WEH_Active Budget";
                GLBudgetEntry."WEH_Budget Type" := AddBudgetLine."Budget Type";
                GLBudgetEntry."G/L Account No." := AddBudgetLine."To G/L Account No.";
                GLBudgetEntry."Date" := AddBudgetLine."To Start Date";
                GLBudgetEntry.VALIDATE("Global Dimension 1 Code", AddBudgetLine."To Global Dimension 1 Code");
                GLBudgetEntry.VALIDATE("Global Dimension 2 Code", AddBudgetLine."To Global Dimension 2 Code");
                GLBudgetEntry.Amount := AddBudgetLine."To Total Amount (LCY)";
                GLBudgetEntry.Description := AddBudgetLine."To Description";
                GLBudgetEntry."User ID" := USERID;
                IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::O THEN
                    GLBudgetEntry."WEH_Long Text" := 'Transfer From G/L No. ' + FORMAT(AddBudgetLine."G/L Account No.") + ' ' +
                                                     'Department ' + FORMAT(AddBudgetLine."Global Dimension 1 Code")
                ELSE
                    IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::C THEN
                        GLBudgetEntry."WEH_Long Text" := 'Transfer From Budget Code ' + FORMAT(AddBudgetLine."Global Dimension 2 Code") + ' ' +
                                                         'Department ' + FORMAT(AddBudgetLine."Global Dimension 1 Code");

                GLBudgetEntry.WEH_Remark := AddBudgetLine.Remark;
                GLBudgetEntry."WEH_Start Date" := AddBudgetLine."Start Date";
                GLBudgetEntry."WEH_End Date" := AddBudgetLine."To End Date";
                GLBudgetEntry."WEH_G/L Budget Name Type" := GLBudgetEntry."WEH_G/L Budget Name Type"::Budget;
                GLBudgetEntry."WEH_Add/Transfer Document No." := AddBudgetLine."Document No.";
                GLBudgetEntry.VALIDATE("Budget Dimension 1 Code", AddBudgetLine."To Budget Dimension 1 Code");
                GLBudgetEntry.VALIDATE("Budget Dimension 2 Code", AddBudgetLine."To Budget Dimension 2 Code");
                GLBudgetEntry.INSERT();
            UNTIL AddBudgetLine.NEXT() = 0;

            Rec."Post to Budget" := GLSetup."WEH_Active Budget";
            Rec.Status := Rec.Status::Posted;
            Rec."Posted by" := USERID;
            Rec.MODIFY();

            EXIT(TRUE);
        END ELSE
            EXIT(FALSE);
    end;

    procedure GetBudgetInfo()
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        GLBudgetEntry: Record "G/L Budget Entry";
        GLEntry: Record "G/L Entry";
        AddBudgetLine: Record "WEH_Add/T. Budget COR Line";
        OutBudgetAmount: Decimal;
        OutPRAmount: Decimal;
        OutPOAmount: Decimal;
        OutActualAmount: Decimal;
        OutAvailableAmount: Decimal;
    begin
        CLEAR(OutBudgetAmount);
        CLEAR(OutPRAmount);
        CLEAR(OutPOAmount);
        CLEAR(OutActualAmount);
        CLEAR(OutAvailableAmount);

        Rec.TestField("Post to Budget");

        GLSetup.Get();

        CLEAR(GLBudgetName);
        GLBudgetName.GET(Rec."Post to Budget");
        GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

        CLEAR(OutBudgetAmount);
        CLEAR(OutPRAmount);
        CLEAR(OutPOAmount);
        CLEAR(OutActualAmount);
        CLEAR(OutAvailableAmount);

        Clear(AddBudgetLine);
        AddBudgetLine.SetRange("Document No.", Rec."No.");
        if AddBudgetLine.FindSet() then begin
            repeat
                IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::O THEN BEGIN
                    CLEAR(GLBudgetEntry);
                    GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", "Global Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("Budget Name", Rec."Post to Budget");
                    GLBudgetEntry.SETRANGE("G/L Account No.", AddBudgetLine."G/L Account No.");
                    GLBudgetEntry.SETRANGE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("WEH_Budget Type", AddBudgetLine."Budget Type");
                    IF GLBudgetEntry.FINDSET() THEN BEGIN
                        REPEAT
                            OutBudgetAmount := OutBudgetAmount + GLBudgetEntry.Amount;
                        UNTIL GLBudgetEntry.NEXT() = 0;
                    END;

                    CLEAR(GLBudgetEntry);
                    GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", "Global Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                    GLBudgetEntry.SETRANGE("G/L Account No.", AddBudgetLine."G/L Account No.");
                    GLBudgetEntry.SETRANGE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("WEH_Budget Type", AddBudgetLine."Budget Type");
                    IF GLBudgetEntry.FindSet() THEN BEGIN
                        REPEAT
                            GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                            OutPRAmount += GLBudgetEntry."WEH_Encumbrance PR Amount";
                            OutPOAmount += GLBudgetEntry."WEH_Encumbrance PO Amount";
                        UNTIL GLBudgetEntry.NEXT() = 0;
                    END;

                    CLEAR(GLEntry);
                    GLEntry.SETCURRENTKEY("G/L Account No.", "Global Dimension 1 Code");
                    GLEntry.SETRANGE("G/L Account No.", AddBudgetLine."G/L Account No.");
                    GLEntry.SETRANGE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                    GLEntry.SETRANGE("Posting Date", GLBudgetName."WEH_Start Date", GLBudgetName."WEH_End Date");
                    IF GLEntry.FINDSET() THEN BEGIN
                        REPEAT
                            OutActualAmount += GLEntry.Amount;
                        UNTIL GLEntry.NEXT() = 0;
                    END;

                    OutAvailableAmount := OutBudgetAmount - OutPRAmount - OutPOAmount - OutActualAmount;
                END ELSE
                    IF AddBudgetLine."Budget Type" = AddBudgetLine."Budget Type"::C THEN BEGIN
                        CLEAR(GLBudgetEntry);
                        GLBudgetEntry.SETCURRENTKEY("Budget Name", "Global Dimension 1 Code", "Global Dimension 2 Code");
                        GLBudgetEntry.SETRANGE("Budget Name", Rec."Post to Budget");
                        GLBudgetEntry.SETRANGE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                        GLBudgetEntry.SETRANGE("Global Dimension 2 Code", AddBudgetLine."Global Dimension 2 Code");
                        GLBudgetEntry.SETRANGE("WEH_Budget Type", AddBudgetLine."Budget Type");
                        IF GLBudgetEntry.FindSet() THEN BEGIN
                            REPEAT
                                OutBudgetAmount += GLBudgetEntry.Amount;
                            UNTIL GLBudgetEntry.NEXT() = 0;
                        END;

                        CLEAR(GLBudgetEntry);
                        GLBudgetEntry.SETCURRENTKEY("Budget Name", "Global Dimension 1 Code", "Global Dimension 2 Code");
                        GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                        GLBudgetEntry.SETRANGE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                        GLBudgetEntry.SETRANGE("Global Dimension 2 Code", AddBudgetLine."Global Dimension 2 Code");
                        GLBudgetEntry.SETRANGE("WEH_Budget Type", AddBudgetLine."Budget Type");
                        IF GLBudgetEntry.FINDSET() THEN BEGIN
                            REPEAT
                                GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                                OutPRAmount += GLBudgetEntry."WEH_Encumbrance PR Amount";
                                OutPOAmount += GLBudgetEntry."WEH_Encumbrance PO Amount";
                            UNTIL GLBudgetEntry.NEXT() = 0;
                        END;

                        CLEAR(GLEntry);
                        GLEntry.SETCURRENTKEY("Global Dimension 1 Code", "Global Dimension 2 Code");
                        GLEntry.SETRANGE("Global Dimension 1 Code", AddBudgetLine."Global Dimension 1 Code");
                        GLEntry.SETRANGE("Global Dimension 2 Code", AddBudgetLine."Global Dimension 2 Code");
                        GLEntry.SETRANGE("Posting Date", GLBudgetName."WEH_Start Date", GLBudgetName."WEH_End Date");
                        GLEntry.SETFILTER("G/L Account No.", GLSetup."WEH_VAT Account");
                        IF GLEntry.FINDSET() THEN BEGIN
                            REPEAT
                                OutActualAmount := OutActualAmount + GLEntry.Amount;
                            UNTIL GLEntry.NEXT() = 0;
                        END;

                        OutAvailableAmount := OutBudgetAmount - OutPRAmount - OutPOAmount - OutActualAmount;
                    END;

                if AddBudgetLine."To Total Amount (LCY)" > OutAvailableAmount then
                    Error('%1 must not more than available budget', AddBudgetLine.FieldCaption("To Total Amount (LCY)"));
            until AddBudgetLine.Next() = 0;
        end;
    end;
}
