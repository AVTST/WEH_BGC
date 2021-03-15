codeunit 50009 "WEH_Budget Control Management"
{
    EventSubscriberInstance = StaticAutomatic;

    trigger OnRun()
    begin

    end;

    procedure DeductPOBudget(VAR PurchaseLine: Record "Purchase Line"; VAR PostedInvNo: Code[20]; VAR PostedInvLineNo: Integer; VAR PONo: Code[20]; VAR POLineNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        PurchaseHeader: Record "Purchase Header";
        NewPurchLine: Record "Purchase Line";
        PurchInvHead: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
    begin
        CLEAR(GLSetup);
        GLSetup.GET();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        CLEAR(GLBudgetName);
        GLBudgetName.GET(PurchaseLine."WEH_Budget Name");
        GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

        CLEAR(PurchaseHeader);
        PurchaseHeader.SETCURRENTKEY("Document Type", "No.");
        PurchaseHeader.SETRANGE("Document Type", PurchaseLine."Document Type");
        PurchaseHeader.SETRANGE("No.", PurchaseLine."Document No.");
        IF PurchaseHeader.FindFirst() THEN BEGIN
            IF PurchaseLine."Qty. to Invoice" <> 0 THEN BEGIN
                CLEAR(PurchInvLine);
                PurchInvLine.SETCURRENTKEY("Document No.", "Line No.");
                PurchInvLine.SETRANGE("Document No.", PostedInvNo);
                PurchInvLine.SETRANGE("Line No.", PostedInvLineNo);
                //PurchInvLine.SETRANGE("Order No.", PurchaseLine."Order No.");
                //PurchInvLine.SETRANGE("Order Line No.", PurchaseLine."Order Line No.");
                //PurchInvLine.SETFILTER("AVTD_Ref. Doc. No.", '<>%1', '');
                IF PurchInvLine.FindFirst() THEN BEGIN
                    CLEAR(PRInLineAmt);
                    CLEAR(PROutLineAmt);
                    CLEAR(PRLineAmt);
                    CLEAR(POInLineAmt);
                    CLEAR(POOutLineAmt);
                    CLEAR(POLineAmt);
                    CLEAR(PRInLineQty);
                    CLEAR(PROutLineQty);
                    CLEAR(PRLineQty);
                    CLEAR(POInLineQty);
                    CLEAR(POOutLineQty);
                    CLEAR(POLineQty);
                    CLEAR(EntryType);

                    PurchInvHead.Get(PurchInvLine."Document No.");
                    if PurchInvHead."Currency Code" = '' then begin
                        POOutLineAmt := PurchInvLine.Amount;
                        POLineAmt := PurchInvLine.Amount * (-1);
                    end else begin
                        POOutLineAmt := round(PurchInvLine.Amount / PurchInvHead."Currency Factor", 0.01, '=');
                        POLineAmt := round(PurchInvLine.Amount / PurchInvHead."Currency Factor", 0.01, '=') * (-1);
                    end;

                    EntryType := EntryType::"Inv. Deduct PO";
                    if NewPurchLine.get(NewPurchLine."Document Type"::Order, PONo, POLineNo) then begin
                        IF POLineAmt <> 0 THEN BEGIN
                            if NewPurchLine."WEH_Budget Type" = NewPurchLine."WEH_Budget Type"::C then
                                InitBudgetEncumbrance(NewPurchLine, EntryType, GLSetup."WEH_G/L for Budget Type C", GLBudgetName."WEH_Encumbrance Name",
                                                      PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                      PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                      PostedInvNo, PostedInvLineNo)
                            else
                                if NewPurchLine."WEH_Budget Type" = NewPurchLine."WEH_Budget Type"::O then
                                    InitBudgetEncumbrance(NewPurchLine, EntryType, NewPurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                                          PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                          PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                          PostedInvNo, PostedInvLineNo);
                        END;
                    end;
                END;
            END;
        END;
    end;

    procedure UpdateInvAmtBudget(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        GLBudgetEncPRPO: Record "WEH_G/L Budget Enc. PR/PO";
        SumRealInv: Decimal;
    begin
        CLEAR(PurchInvLine);
        PurchInvLine.SETCURRENTKEY("Document No.", "Line No.");
        PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
        IF PurchInvLine.FindSet() THEN BEGIN
            REPEAT
                CLEAR(GLBudgetEncPRPO);
                GLBudgetEncPRPO.SETCURRENTKEY("Posted Invoice No.", "Posted Invoice Line No.");
                GLBudgetEncPRPO.SETRANGE("Posted Invoice No.", PurchInvLine."Document No.");
                GLBudgetEncPRPO.SETRANGE("Posted Invoice Line No.", PurchInvLine."Line No.");
                IF GLBudgetEncPRPO.FindFirst() THEN BEGIN
                    CLEAR(SumRealInv);
                    IF PurchInvHeader."Currency Code" = '' then
                        SumRealInv := PurchInvLine.Amount
                    ELSE
                        SumRealInv := Round(PurchInvLine.Amount / PurchInvHeader."Currency Factor", 0.01, '=');

                    GLBudgetEncPRPO."Actual Amount Exc. VAT" := SumRealInv;
                    GLBudgetEncPRPO.Modify();
                END;
            UNTIL PurchInvLine.Next() = 0;
        END;
    end;

    procedure AdjustInvAmtBudget(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        POHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        GLBudgetEntry: Record "G/L Budget Entry";
        GLBudgetName: Record "G/L Budget Name";
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
    begin
        CLEAR(PurchInvLine);
        PurchInvLine.SETCURRENTKEY("Document No.", "Line No.");
        PurchInvLine.SETRANGE("Document No.", PurchInvHeader."No.");
        IF PurchInvLine.FindSet() THEN BEGIN
            REPEAT
                CLEAR(PurchRcptLine);
                PurchRcptLine.SETCURRENTKEY("Document No.", "Line No.");
                PurchRcptLine.SETRANGE("Document No.", PurchInvLine."Receipt No.");
                PurchRcptLine.SETRANGE("Line No.", PurchInvLine."Receipt Line No.");
                IF PurchRcptLine.FindFirst() THEN BEGIN
                    CLEAR(PurchaseLine);
                    PurchaseLine.SETCURRENTKEY("Document Type", "Document No.");
                    PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SETRANGE("Document No.", PurchRcptLine."Order No.");
                    PurchaseLine.SETRANGE("Line No.", PurchRcptLine."Order Line No.");
                    PurchaseLine.SETFILTER("AVTD_Ref. Doc. No.", '<>%1', '');
                    IF PurchaseLine.FindFirst() THEN BEGIN
                        if POHeader.get(POHeader."Document Type"::Order, PurchRcptLine."Order No.") then begin
                            if POHeader."WEH_Budget Document Type" = POHeader."WEH_Budget Document Type"::Corporate then begin
                                IF (PurchaseLine.Quantity = PurchaseLine."Quantity Invoiced") AND (PurchaseLine.Quantity <> 0) THEN BEGIN
                                    CLEAR(GLBudgetEntry);
                                    GLBudgetEntry.SETCURRENTKEY("Entry No.");
                                    IF PurchaseLine."WEH_Budget Name" <> '' THEN begin
                                        CLEAR(GLBudgetName);
                                        GLBudgetName.GET(PurchaseLine."WEH_Budget Name");
                                        GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                                        GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                                    end;
                                    GLBudgetEntry.SETRANGE("WEH_Ref. Document No.", PurchaseLine."AVTD_Ref. Doc. No.");
                                    GLBudgetEntry.SETRANGE("WEH_Ref. Document Line No.", PurchaseLine."AVTD_Ref. Line No.");
                                    GLBudgetEntry.SETRANGE("WEH_Ref. Document Type", GLBudgetEntry."WEH_Ref. Document Type"::Encumbrance);
                                    IF GLBudgetEntry.FindFirst() THEN BEGIN
                                        GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PO Amount");
                                        IF GLBudgetEntry."WEH_Encumbrance PO Amount" <> 0 THEN BEGIN
                                            CLEAR(PRInLineAmt);
                                            CLEAR(PROutLineAmt);
                                            CLEAR(PRLineAmt);
                                            CLEAR(POInLineAmt);
                                            CLEAR(POOutLineAmt);
                                            CLEAR(POLineAmt);
                                            CLEAR(PRInLineQty);
                                            CLEAR(PROutLineQty);
                                            CLEAR(PRLineQty);
                                            CLEAR(POInLineQty);
                                            CLEAR(POOutLineQty);
                                            CLEAR(POLineQty);
                                            CLEAR(EntryType);
                                            EntryType := EntryType::"Adjust PO";
                                            POOutLineAmt := GLBudgetEntry."WEH_Encumbrance PO Amount" * (-1);
                                            POLineAmt := POOutLineAmt;

                                            if PurchaseLine."WEH_Budget Type" = PurchaseLine."WEH_Budget Type"::O then
                                                InitBudgetEncumbrance(PurchaseLine, EntryType, PurchaseLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                                                      PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                                      PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                                      '', 0)
                                            else
                                                if PurchaseLine."WEH_Budget Type" = PurchaseLine."WEH_Budget Type"::C then
                                                    InitBudgetEncumbrance(PurchaseLine, EntryType, PurchaseLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                                                          PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                                          PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                                          '', 0);
                                        END;
                                    END;
                                END;
                            END;
                        end;
                    end;
                END;
            UNTIL PurchInvLine.Next() = 0;
        END;
    end;

    procedure CommitPO(VAR PurchaseHead: Record "Purchase Header")
    begin
        PurchaseHead.testfield("Order Date");

        IF PurchaseHead."WEH_Commit PO" = PurchaseHead."WEH_Commit PO"::COMMIT THEN
            exit;

        IF CONFIRM('Do you want to commit PO No. %1?', TRUE, PurchaseHead."No.") THEN BEGIN
            //IF PurchaseHead."WEH_Budget Document Type" = PurchaseHead."WEH_Budget Document Type"::Corporate THEN BEGIN
            CheckPurchLineInit(PurchaseHead."Document Type", PurchaseHead."No.");

            if CommitByLine(PurchaseHead."Document Type", PurchaseHead."No.") then begin
                PurchaseHead.VALIDATE("WEH_Commit PO", PurchaseHead."WEH_Commit PO"::Commit);
                PurchaseHead.Modify();

                Message('Commit PO complete');
            end else
                Error('Cannot commit PO');
            //end;
        end;
    end;

    local procedure CommitByLine(DocType: Enum "Purchase Document Type"; DocNo: Code[20]): Boolean
    var
        GLSetup: Record "General Ledger Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        GLBudgetName: Record "G/L Budget Name";
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        NewPurchLine: Record "Purchase Line";
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
        RefGLBudgetEntryNo: Integer;
        ReversePR: Boolean;
        ReversePO: Boolean;
        DocPass: Boolean;
        ErrorMismatch: Label '%1 mismatch with PR';
    begin
        Clear(DocPass);

        CLEAR(GLSetup);
        GLSetup.GET();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        Clear(PurchSetup);
        PurchSetup.Get();

        Clear(PurchHead);
        PurchHead.Get(DocType, DocNo);

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETFILTER("No.", '<>%1', '');
        PurchLine.SETFILTER("WEH_Budget Type", '<>%1', PurchLine."WEH_Budget Type"::" ");
        PurchLine.SETFILTER("AVTD_Ref. Doc. No.", '<>%1', '');
        IF PurchLine.FindSet() THEN BEGIN
            REPEAT
                CLEAR(NewPurchLine);
                IF NewPurchLine.GET(NewPurchLine."Document Type"::Quote, PurchLine."AVTD_Ref. Doc. No.", PurchLine."AVTD_Ref. Line No.") THEN begin
                    IF PurchLine."Outstanding Amt. Ex. VAT (LCY)" > (NewPurchLine."Outstanding Amt. Ex. VAT (LCY)" + PurchSetup."WEH_PO Outstanding Diff.") THEN
                        Error('Outstanding Amt. Ex. VAT (LCY) cannot more than %1 in PR No. %2 Line No. %3', NewPurchLine."Outstanding Amt. Ex. VAT (LCY)", NewPurchLine."Document No.", NewPurchLine."Line No.");

                    if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then begin
                        if PurchLine.Type <> NewPurchLine.Type then
                            Error(ErrorMismatch, PurchLine.FieldCaption(Type));
                        if PurchLine."No." <> NewPurchLine."No." then
                            Error(ErrorMismatch, PurchLine.FieldCaption("No."));
                        if PurchLine."Shortcut Dimension 1 Code" <> NewPurchLine."Shortcut Dimension 1 Code" then
                            Error(ErrorMismatch, PurchLine.FieldCaption("Shortcut Dimension 1 Code"));
                        if PurchLine."WEH_Budget Name" <> NewPurchLine."WEH_Budget Name" then
                            Error(ErrorMismatch, PurchLine.FieldCaption("WEH_Budget Name"));
                    end else
                        if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C then begin
                            if PurchLine."Shortcut Dimension 1 Code" <> NewPurchLine."Shortcut Dimension 1 Code" then
                                Error(ErrorMismatch, PurchLine.FieldCaption("Shortcut Dimension 1 Code"));
                            if PurchLine."Shortcut Dimension 2 Code" <> NewPurchLine."Shortcut Dimension 2 Code" then
                                Error(ErrorMismatch, PurchLine.FieldCaption("Shortcut Dimension 2 Code"));
                            if PurchLine."WEH_Budget Name" <> NewPurchLine."WEH_Budget Name" then
                                Error(ErrorMismatch, PurchLine.FieldCaption("WEH_Budget Name"));
                        end;
                end;

                CLEAR(PRInLineAmt);
                CLEAR(PROutLineAmt);
                CLEAR(PRLineAmt);
                CLEAR(POInLineAmt);
                CLEAR(POOutLineAmt);
                CLEAR(POLineAmt);
                CLEAR(PRInLineQty);
                CLEAR(PROutLineQty);
                CLEAR(PRLineQty);
                CLEAR(POInLineQty);
                CLEAR(POOutLineQty);
                CLEAR(POLineQty);
                CLEAR(EntryType);
                CLEAR(EntryType);
                CLEAR(ReversePR);
                CLEAR(ReversePO);

                CLEAR(GLBudgetName);
                GLBudgetName.GET(PurchLine."WEH_Budget Name");
                GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                CLEAR(RefGLBudgetEntryNo);
                RefGLBudgetEntryNo := FindRefGLBudgetEntry(PurchLine);

                ReversePR := TRUE;
                ReversePO := TRUE;

                BudgetReverseEntry(RefGLBudgetEntryNo, ReversePR, ReversePO,
                                   PRInLineAmt, PROutLineAmt, PRLineAmt,
                                   POInLineAmt, POOutLineAmt, POLineAmt,
                                   PRInLineQty, PROutLineQty, PRLineQty,
                                   POInLineQty, POOutLineQty, POLineQty);

                POINLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)";
                POLineAmt := POINLineAmt;

                EntryType := EntryType::"Commit PO";

                if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C then
                    InitBudgetEncumbrance(PurchLine, EntryType, GLSetup."WEH_G/L for Budget Type C", GLBudgetName."WEH_Encumbrance Name",
                                          PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                          PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                          '', 0)
                else
                    if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then
                        InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                              PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                              PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                              '', 0);
            until PurchLine.Next() = 0;

            DocPass := true;
        end;

        exit(DocPass);
    end;

    procedure UncommitPO(VAR PurchaseHead: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchaseHead.testfield("WEH_Commit PO", PurchaseHead."WEH_Commit PO"::Commit);
        PurchaseHead.testfield(Status, PurchaseHead.Status::Open);
        PurchaseHead.testfield("Order Date");

        PurchaseHead.CheckReceived('uncommit');

        IF CONFIRM('Do you want to Un-Commit PO in PO No. %1 ?', TRUE, PurchaseHead."No.") THEN BEGIN
            IF LineUncommitPO(PurchaseHead) then begin
                PurchaseHead.VALIDATE("WEH_Commit PO", PurchaseHead."WEH_Commit PO"::" ");
                PurchaseHead.Modify();

                Message('Uncommit PO complete');
            end else
                Error('Cannot uncommit PO');
        end;
    end;

    local procedure LineUncommitPO(VAR PurchHead: Record "Purchase Header"): Boolean;
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        PurchLine: Record "Purchase Line";
        NewPurchLine: Record "Purchase Line";
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
        RefGLBudgetEntryNo: Integer;
        ReversePR: Boolean;
        ReversePO: Boolean;
        DocPass: Boolean;
    begin
        Clear(DocPass);

        CLEAR(GLSetup);
        GLSetup.GET();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETFILTER("No.", '<>%1', '');
        PurchLine.SETFILTER("WEH_Budget Type", '<>%1', PurchLine."WEH_Budget Type"::" ");
        IF PurchLine.FindSet() THEN BEGIN
            REPEAT
                CLEAR(PRInLineAmt);
                CLEAR(PROutLineAmt);
                CLEAR(PRLineAmt);
                CLEAR(POInLineAmt);
                CLEAR(POOutLineAmt);
                CLEAR(POLineAmt);
                CLEAR(PRInLineQty);
                CLEAR(PROutLineQty);
                CLEAR(PRLineQty);
                CLEAR(POInLineQty);
                CLEAR(POOutLineQty);
                CLEAR(POLineQty);
                CLEAR(EntryType);
                CLEAR(ReversePR);
                CLEAR(ReversePO);

                CLEAR(GLBudgetName);
                GLBudgetName.GET(PurchLine."WEH_Budget Name");
                GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                CLEAR(RefGLBudgetEntryNo);
                RefGLBudgetEntryNo := FindRefGLBudgetEntry(PurchLine);

                ReversePR := TRUE;
                ReversePO := TRUE;

                BudgetReverseEntry(RefGLBudgetEntryNo, ReversePR, ReversePO,
                                   PRInLineAmt, PROutLineAmt, PRLineAmt,
                                   POInLineAmt, POOutLineAmt, POLineAmt,
                                   PRInLineQty, PROutLineQty, PRLineQty,
                                   POInLineQty, POOutLineQty, POLineQty);

                EntryType := EntryType::"Un-Commit PO";

                CLEAR(NewPurchLine);
                NewPurchLine.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
                NewPurchLine.SETRANGE("Document No.", PurchLine."AVTD_Ref. Doc. No.");
                NewPurchLine.SETRANGE("Line No.", PurchLine."AVTD_Ref. Line No.");
                IF NewPurchLine.FindFirst() THEN;

                PRINLineAmt := NewPurchLine."Outstanding Amt. Ex. VAT (LCY)";
                PRLineAmt := NewPurchLine."Outstanding Amt. Ex. VAT (LCY)";
                POOutLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)";
                POLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)" * -1;

                if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C then
                    InitBudgetEncumbrance(PurchLine, EntryType, GLSetup."WEH_G/L for Budget Type C", GLBudgetName."WEH_Encumbrance Name",
                                          PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                          PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                          '', 0)
                else
                    if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then
                        InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                              PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                              PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                              '', 0);
            until PurchLine.Next() = 0;

            DocPass := true;
        end;

        exit(DocPass);
    end;

    procedure CheckBudget(VAR PurchaseHead: Record "Purchase Header")
    begin
        PurchaseHead.TESTFIELD("Shortcut Dimension 1 Code");
        PurchaseHead.TESTFIELD("Document Date");

        IF PurchaseHead."WEH_Check Budget" = PurchaseHead."WEH_Check Budget"::PASS THEN
            //ERROR('Document No. %1 is already checked budget and passed', PurchaseHead."No.");
            exit;

        IF CONFIRM('Do you want to check budget for PR No. %1?', TRUE, PurchaseHead."No.") THEN BEGIN
            CheckPurchLineInit(PurchaseHead."Document Type", PurchaseHead."No.");

            if CheckBudgetByLine(PurchaseHead."Document Type", PurchaseHead."No.") then
                PurchaseHead."WEH_Check Budget" := PurchaseHead."WEH_Check Budget"::PASS
            else
                PurchaseHead."WEH_Check Budget" := PurchaseHead."WEH_Check Budget"::"Not Pass";

            PurchaseHead.Modify();

            MESSAGE('Check budget complete');
        END;
    end;

    local procedure CheckBudgetByLine(DocType: Enum "Purchase Document Type"; DocNo: Code[20]): Boolean
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        GLBudgetEntry: Record "G/L Budget Entry";
        GLEntry: Record "G/L Entry";
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        NewPurchLine: Record "Purchase Line";
        DocAmtTotal: Decimal;
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        DocPass: Boolean;
    begin
        Clear(DocPass);

        CLEAR(GLSetup);
        GLSetup.GET();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        Clear(PurchHead);
        PurchHead.Get(DocType, DocNo);

        FindAmountPerDocument(PurchHead, DocAmtTotal);
        CheckAvailableBudget(PurchHead);

        CLEAR(NewPurchLine);
        NewPurchLine.SETCURRENTKEY("Document Type", "Document No.");
        NewPurchLine.SETRANGE("Document No.", PurchHead."No.");
        NewPurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        NewPurchLine.SETRANGE("WEH_Check Budget", NewPurchLine."WEH_Check Budget"::"Not Pass");
        NewPurchLine.SETFILTER("No.", '<>%1', '');
        IF NewPurchLine.IsEmpty THEN BEGIN
            CLEAR(PurchLine);
            PurchLine.SETCURRENTKEY("Document Type", "Document No.");
            PurchLine.SETRANGE("Document No.", PurchHead."No.");
            PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
            PurchLine.SETRANGE("WEH_Check Budget", PurchLine."WEH_Check Budget"::Pass);
            IF PurchLine.FindSet() THEN BEGIN
                REPEAT
                    CLEAR(PRInLineAmt);
                    CLEAR(PROutLineAmt);
                    CLEAR(PRLineAmt);
                    CLEAR(POInLineAmt);
                    CLEAR(POOutLineAmt);
                    CLEAR(POLineAmt);
                    CLEAR(PRInLineQty);
                    CLEAR(PROutLineQty);
                    CLEAR(PRLineQty);
                    CLEAR(POInLineQty);
                    CLEAR(POOutLineQty);
                    CLEAR(POLineQty);
                    CLEAR(EntryType);

                    CLEAR(GLBudgetName);
                    GLBudgetName.GET(PurchLine."WEH_Budget Name");
                    GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                    PRInLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)";

                    EntryType := EntryType::"Check Budget";
                    PRLineAmt := PRInLineAmt;

                    if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C then
                        InitBudgetEncumbrance(PurchLine, EntryType, GLSetup."WEH_G/L for Budget Type C", GLBudgetName."WEH_Encumbrance Name",
                                              PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                              PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                              '', 0)
                    else
                        if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then
                            InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                                  PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                  PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                  '', 0);
                until PurchLine.Next() = 0;
            end;

            DocPass := true;
        end;

        exit(DocPass);
    end;

    local procedure CheckAvailableBudget(VAR PurchHead: Record "Purchase Header")
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        GLBudgetEntry: Record "G/L Budget Entry";
        GLEntry: Record "G/L Entry";
        PurchLine: Record "Purchase Line";
        NewPurchLine: Record "Purchase Line";
        BudgetAmt: Decimal;
        EncumbranceAmt: Decimal;
        ActualAmt: Decimal;
        AvaiableBudget: Decimal;
        BudgetQty: Decimal;
        EncumbranceQty: Decimal;
        ActualQty: Decimal;
        AvailableQty: Decimal;
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
        PurchLineVATAmt: Decimal;
        AccumPurchLineVATAmt: Decimal;
        TotalPurchLineVATAmt: Decimal;
        DiffVATAmt: Decimal;
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        LinePass: Boolean;
    begin
        CLEAR(GLSetup);
        GLSetup.GET();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        PurchLine.ModifyAll("WEH_Check Budget", PurchLine."WEH_Check Budget"::" ");
        Commit();

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        PurchLine.SETRANGE(Type, PurchLine.Type::"G/L Account");
        PurchLine.SETFILTER("No.", '<>%1', '');
        IF PurchLine.FindSet() THEN BEGIN
            REPEAT
                Clear(LinePass);
                CLEAR(BudgetAmt);
                CLEAR(EncumbranceAmt);
                CLEAR(ActualAmt);
                CLEAR(AvaiableBudget);
                CLEAR(BudgetQty);
                CLEAR(EncumbranceQty);
                CLEAR(ActualQty);
                CLEAR(AvailableQty);
                CLEAR(PRInLineAmt);
                CLEAR(PROutLineAmt);
                CLEAR(PRLineAmt);
                CLEAR(POInLineAmt);
                CLEAR(POOutLineAmt);
                CLEAR(POLineAmt);
                CLEAR(PRInLineQty);
                CLEAR(PROutLineQty);
                CLEAR(PRLineQty);
                CLEAR(POInLineQty);
                CLEAR(POOutLineQty);
                CLEAR(POLineQty);
                CLEAR(EntryType);

                CLEAR(GLBudgetName);
                GLBudgetName.GET(PurchLine."WEH_Budget Name");
                GLBudgetName.TESTFIELD("WEH_Encumbrance Name");
                GLBudgetName.TESTFIELD("WEH_Start Date");
                GLBudgetName.TESTFIELD("WEH_End Date");

                IF PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O THEN BEGIN
                    CLEAR(GLBudgetEntry);
                    GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", Date);
                    GLBudgetEntry.SETRANGE("Budget Name", PurchLine."WEH_Budget Name");
                    GLBudgetEntry.SETRANGE("G/L Account No.", PurchLine."No.");
                    GLBudgetEntry.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("WEH_Budget Type", PurchLine."WEH_Budget Type");
                    IF GLBudgetEntry.FINDSET() THEN BEGIN
                        REPEAT
                            BudgetAmt += GLBudgetEntry.Amount;
                        UNTIL GLBudgetEntry.NEXT() = 0;
                    END;

                    CLEAR(GLBudgetEntry);
                    GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", Date);
                    GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                    GLBudgetEntry.SETRANGE("G/L Account No.", PurchLine."No.");
                    GLBudgetEntry.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                    GLBudgetEntry.SETRANGE("WEH_Budget Type", PurchLine."WEH_Budget Type");
                    IF GLBudgetEntry.FINDSET() THEN BEGIN
                        REPEAT
                            GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                            EncumbranceAmt += GLBudgetEntry."WEH_Encumbrance PR Amount";
                            EncumbranceAmt += GLBudgetEntry."WEH_Encumbrance PO Amount";
                            EncumbranceAmt += GLBudgetEntry."WEH_Encumbrance PI Amount";
                        UNTIL GLBudgetEntry.NEXT = 0;
                    END;

                    CLEAR(GLEntry);
                    GLEntry.SETCURRENTKEY("G/L Account No.", "Posting Date");
                    GLEntry.SETRANGE("G/L Account No.", PurchLine."No.");
                    GLEntry.SETRANGE("Posting Date", GLBudgetName."WEH_Start Date", GLBudgetName."WEH_End Date");
                    GLEntry.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                    IF GLEntry.FINDSET() THEN BEGIN
                        REPEAT
                            ActualAmt := ActualAmt + GLEntry.Amount;
                        UNTIL GLEntry.NEXT() = 0;
                    END;

                    AvaiableBudget := BudgetAmt - EncumbranceAmt - ActualAmt;

                    //PRInLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)";
                    CLEAR(NewPurchLine);
                    NewPurchLine.SETCURRENTKEY("Document Type", "Document No.");
                    NewPurchLine.SETRANGE("Document No.", PurchLine."Document No.");
                    NewPurchLine.SETRANGE("Document Type", PurchLine."Document Type");
                    NewPurchLine.SETRANGE(Type, NewPurchLine.Type::"G/L Account");
                    NewPurchLine.SETRANGE("No.", PurchLine."No.");
                    NewPurchLine.SETRANGE("Shortcut Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                    NewPurchLine.SETRANGE("WEH_Budget Type", NewPurchLine."WEH_Budget Type"::O);
                    NewPurchLine.CalcSums("Outstanding Amt. Ex. VAT (LCY)");
                    PRInLineAmt := NewPurchLine."Outstanding Amt. Ex. VAT (LCY)";

                    IF PRInLineAmt <= AvaiableBudget THEN
                        LinePass := TRUE;
                END ELSE
                    IF PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C THEN BEGIN
                        CLEAR(GLBudgetEntry);
                        GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", Date);
                        GLBudgetEntry.SETRANGE("Budget Name", PurchLine."WEH_Budget Name");
                        GLBudgetEntry.SETRANGE("G/L Account No.", GLSetup."WEH_G/L for Budget Type C");
                        GLBudgetEntry.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                        GLBudgetEntry.SETRANGE("Global Dimension 2 Code", PurchLine."Shortcut Dimension 2 Code");
                        IF GLBudgetEntry.FINDSET() THEN BEGIN
                            REPEAT
                                BudgetAmt += GLBudgetEntry.Amount;
                            UNTIL GLBudgetEntry.NEXT() = 0;
                        END;

                        CLEAR(GLBudgetEntry);
                        GLBudgetEntry.SETCURRENTKEY("Budget Name", "G/L Account No.", Date);
                        GLBudgetEntry.SETRANGE("Budget Name", GLBudgetName."WEH_Encumbrance Name");
                        GLBudgetEntry.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                        GLBudgetEntry.SETRANGE("Global Dimension 2 Code", PurchLine."Shortcut Dimension 2 Code");
                        IF GLBudgetEntry.FINDSET() THEN BEGIN
                            REPEAT
                                GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PR Amount", "WEH_Encumbrance PO Amount");
                                EncumbranceAmt += GLBudgetEntry."WEH_Encumbrance PR Amount";
                                EncumbranceAmt += GLBudgetEntry."WEH_Encumbrance PO Amount";
                                EncumbranceAmt += GLBudgetEntry."WEH_Encumbrance PI Amount";
                            UNTIL GLBudgetEntry.NEXT() = 0;
                        END;

                        CLEAR(GLEntry);
                        GLEntry.SETCURRENTKEY("G/L Account No.", "Posting Date");
                        GLEntry.SETFILTER("G/L Account No.", GLSetup."WEH_VAT Account");
                        GLEntry.SETRANGE("Global Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                        GLEntry.SETRANGE("Global Dimension 2 Code", PurchLine."Shortcut Dimension 2 Code");
                        GLEntry.SETRANGE("Posting Date", GLBudgetName."WEH_Start Date", GLBudgetName."WEH_End Date");
                        IF GLEntry.FINDSET() THEN BEGIN
                            REPEAT
                                ActualAmt += GLEntry.Amount;
                            UNTIL GLEntry.NEXT() = 0;
                        END;

                        AvaiableBudget := BudgetAmt - EncumbranceAmt - ActualAmt;

                        //PRInLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)";
                        CLEAR(NewPurchLine);
                        NewPurchLine.SETCURRENTKEY("Document Type", "Document No.");
                        NewPurchLine.SETRANGE("Document No.", PurchLine."Document No.");
                        NewPurchLine.SETRANGE("Document Type", PurchLine."Document Type");
                        NewPurchLine.SETRANGE("Shortcut Dimension 1 Code", PurchLine."Shortcut Dimension 1 Code");
                        NewPurchLine.SETRANGE("Shortcut Dimension 2 Code", PurchLine."Shortcut Dimension 2 Code");
                        NewPurchLine.SETRANGE(Type, NewPurchLine.Type::"G/L Account");
                        NewPurchLine.SETFILTER("No.", '<>%1', '');
                        NewPurchLine.SETRANGE("WEH_Budget Type", NewPurchLine."WEH_Budget Type"::C);
                        NewPurchLine.CalcSums("Outstanding Amt. Ex. VAT (LCY)");
                        PRInLineAmt := NewPurchLine."Outstanding Amt. Ex. VAT (LCY)";

                        IF PRInLineAmt <= AvaiableBudget THEN
                            LinePass := TRUE;
                    END else
                        IF PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::P THEN
                            LinePass := TRUE;

                if LinePass then
                    PurchLine."WEH_Check Budget" := PurchLine."WEH_Check Budget"::Pass
                else
                    PurchLine."WEH_Check Budget" := PurchLine."WEH_Check Budget"::"Not Pass";

                PurchLine.MODIFY();
            UNTIL PurchLine.NEXT() = 0;
        END;

        Commit();
    end;

    procedure UncheckBudget(VAR PurchaseHead: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchaseHead.testfield("WEH_Check Budget", PurchaseHead."WEH_Check Budget"::Pass);
        PurchaseHead.testfield(Status, PurchaseHead.Status::Open);

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", PurchLine."Document No.");
        PurchLine.SETRANGE("Document No.", PurchaseHead."No.");
        PurchLine.SETRANGE("Document Type", PurchaseHead."Document Type");
        PurchLine.SETFILTER("AVTD_Ref. Doc. No.", '<>%1', '');
        IF PurchLine.FINDFIRST THEN
            ERROR('Document No. %1 cannot uncheck budget because Line No. %1 is already copied to PO No. %2', PurchaseHead."No.", PurchLine."Line No.", PurchLine."AVTD_Ref. Doc. No.");

        IF CONFIRM('Do you want to uncheck budget for Document No. %1?', TRUE, PurchaseHead."No.") THEN BEGIN
            if LineUncheckBudget(PurchaseHead) then begin
                PurchaseHead."WEH_Check Budget" := PurchaseHead."WEH_Check Budget"::" ";
                PurchaseHead.MODIFY();

                Message('Uncheck budget complete');
            end else
                Error('Cannot uncheck budget');
        END;
    end;

    local procedure LineUncheckBudget(VAR PurchHead: Record "Purchase Header"): Boolean;
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        PurchLine: Record "Purchase Line";
        NewPurchLine: Record "Purchase Line";
        DocAmtTotal: Decimal;
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        ReversePR: Boolean;
        ReversePO: Boolean;
        RefGLBudgetEntryNo: Integer;
        LinesPass: Boolean;
    begin
        Clear(LinesPass);

        CLEAR(GLSetup);
        GLSetup.GET();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        PurchLine.SETFILTER("No.", '<>%1', '');
        PurchLine.SETFILTER("WEH_Budget Type", '<>%1', PurchLine."WEH_Budget Type"::" ");
        IF PurchLine.FINDSET THEN BEGIN
            REPEAT
                CLEAR(PRInLineAmt);
                CLEAR(PROutLineAmt);
                CLEAR(PRLineAmt);
                CLEAR(POInLineAmt);
                CLEAR(POOutLineAmt);
                CLEAR(POLineAmt);
                CLEAR(PRInLineQty);
                CLEAR(PROutLineQty);
                CLEAR(PRLineQty);
                CLEAR(POInLineQty);
                CLEAR(POOutLineQty);
                CLEAR(POLineQty);
                CLEAR(EntryType);
                CLEAR(ReversePR);
                CLEAR(ReversePO);

                CLEAR(GLBudgetName);
                GLBudgetName.GET(PurchLine."WEH_Budget Name");
                GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                CLEAR(RefGLBudgetEntryNo);
                RefGLBudgetEntryNo := FindRefGLBudgetEntry(PurchLine);

                ReversePR := TRUE;
                ReversePO := FALSE;

                BudgetReverseEntry(RefGLBudgetEntryNo, ReversePR, ReversePO,
                                   PRInLineAmt, PROutLineAmt, PRLineAmt,
                                   POInLineAmt, POOutLineAmt, POLineAmt,
                                   PRInLineQty, PROutLineQty, PRLineQty,
                                   POInLineQty, POOutLineQty, POLineQty);

                EntryType := EntryType::"Un-Check Budget";

                IF PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C THEN
                    InitBudgetEncumbrance(PurchLine, EntryType, GLSetup."WEH_G/L for Budget Type C", GLBudgetName."WEH_Encumbrance Name",
                                          PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                          PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                          '', 0)
                else
                    if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then
                        InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                              PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                              PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                              '', 0);

                PurchLine."WEH_Check Budget" := PurchLine."WEH_Check Budget"::" ";
                PurchLine.MODIFY();
            UNTIL PurchLine.NEXT() = 0;

            LinesPass := true;
        END;

        exit(LinesPass);
    end;

    local procedure BudgetReverseEntry(RefGLBudgetEntryNo: Integer; ReversePR: Boolean; ReversePO: Boolean;
                                       Var PRInLineAmt: Decimal; Var PROutLineAmt: Decimal; Var PRLineAmt: Decimal;
                                       Var POInLineAmt: Decimal; Var POOutLineAmt: Decimal; Var POLineAmt: Decimal;
                                       Var PRInLineQty: Decimal; Var PROutLineQty: Decimal; Var PRLineQty: Decimal;
                                       Var POInLineQty: Decimal; Var POOutLineQty: Decimal; Var POLineQty: Decimal);
    var
        GLBudgetEncPRPO: Record "WEH_G/L Budget Enc. PR/PO";

    begin
        CLEAR(GLBudgetEncPRPO);
        GLBudgetEncPRPO.SETCURRENTKEY("Entry No.");
        GLBudgetEncPRPO.SETRANGE("G/L Budget Entry No.", RefGLBudgetEntryNo);
        IF GLBudgetEncPRPO.FindLast() THEN BEGIN
            IF ReversePR THEN BEGIN
                IF GLBudgetEncPRPO."PR Amount" <> 0 THEN BEGIN
                    IF GLBudgetEncPRPO."PR Amount" < 0 THEN BEGIN
                        PRInLineAmt := ABS(GLBudgetEncPRPO."PR Amount");
                        PROutLineAmt := 0;
                        PRLineAmt := -GLBudgetEncPRPO."PR Amount";
                    END ELSE BEGIN
                        PRInLineAmt := 0;
                        PROutLineAmt := ABS(GLBudgetEncPRPO."PR Amount");
                        PRLineAmt := -GLBudgetEncPRPO."PR Amount";
                    END;
                END;
                IF GLBudgetEncPRPO."PR Quantity" <> 0 THEN BEGIN
                    IF GLBudgetEncPRPO."PR Quantity" < 0 THEN BEGIN
                        PRInLineQty := ABS(GLBudgetEncPRPO."PR Quantity");
                        PROutLineQty := 0;
                        PRLineQty := -GLBudgetEncPRPO."PR Quantity";
                    END ELSE BEGIN
                        PRInLineQty := 0;
                        PROutLineQty := ABS(GLBudgetEncPRPO."PR Quantity");
                        PRLineQty := -GLBudgetEncPRPO."PR Quantity";
                    END;
                END;
            END;

            IF ReversePO THEN BEGIN
                IF GLBudgetEncPRPO."PO Amount" <> 0 THEN BEGIN
                    IF GLBudgetEncPRPO."PO Amount" < 0 THEN BEGIN
                        POInLineAmt := ABS(GLBudgetEncPRPO."PO Amount");
                        POOutLineAmt := 0;
                        POLineAmt := -GLBudgetEncPRPO."PO Amount";
                    END ELSE BEGIN
                        POInLineAmt := 0;
                        POOutLineAmt := ABS(GLBudgetEncPRPO."PO Amount");
                        POLineAmt := -GLBudgetEncPRPO."PO Amount";
                    END;
                END;

                IF GLBudgetEncPRPO."PO Quantity" <> 0 THEN BEGIN
                    IF GLBudgetEncPRPO."PO Quantity" < 0 THEN BEGIN
                        POInLineQty := ABS(GLBudgetEncPRPO."PO Quantity");
                        POOutLineQty := 0;
                        POLineQty := -GLBudgetEncPRPO."PO Quantity";
                    END ELSE BEGIN
                        POInLineQty := 0;
                        POOutLineQty := ABS(GLBudgetEncPRPO."PO Quantity");
                        POLineQty := -GLBudgetEncPRPO."PO Quantity";
                    END;
                END;
            END;
        END;
    end;

    local procedure CheckPurchLineInit(DocType: Enum "Purchase Document Type"; DocNo: Code[20])
    var
        PurchLine: Record "Purchase Line";
    begin
        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document No.", DocNo);
        PurchLine.SETRANGE("Document Type", DocType);
        PurchLine.SETFILTER("No.", '<>%1', '');
        IF PurchLine.FindSet() THEN BEGIN
            REPEAT
                PurchLine.TESTFIELD("Gen. Prod. Posting Group");
                PurchLine.TESTFIELD("VAT Prod. Posting Group");
                PurchLine.TESTFIELD("AVF_WHT Product Posting Group");

                IF PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::" " THEN
                    ERROR('Budget Type must not be blank on Document No. %1 Line No. %2', PurchLine."Document No.", PurchLine."Line No.");

                IF (PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O) AND (PurchLine."Shortcut Dimension 1 Code" = '') THEN
                    ERROR('Budget Type O must has Department on Document No. %1 Line No. %2', PurchLine."Document No.", PurchLine."Line No.");

                IF (PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C) AND (PurchLine."Shortcut Dimension 1 Code" = '') THEN
                    ERROR('Budget Type C must has Department on Document No. %1 Line No. %2', PurchLine."Document No.", PurchLine."Line No.");

                IF (PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O) AND (PurchLine."Shortcut Dimension 2 Code" <> '') THEN
                    ERROR('Budget Type O must leave Budget Code blank on Document No. %1 Line No. %2', PurchLine."Document No.", PurchLine."Line No.");

                IF (PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C) AND (PurchLine."Shortcut Dimension 2 Code" = '') THEN
                    ERROR('Budget Type C must has Budget Code Document No. %1 Line No. %2', PurchLine."Document No.", PurchLine."Line No.");
            UNTIL PurchLine.NEXT() = 0;
        END else
            Error('Nothing to process');
    end;

    local procedure InitBudgetEncumbrance(VAR PurchLine: Record "Purchase Line"; VAR EntryType: Enum "WEH_Budget Enc. Entry Type"; VAR GLAccNo: Code[20]; VAR OldBudgetName: Code[10]; VAR PR_In_Amt: Decimal; VAR PR_Out_Amt: Decimal; VAR PR_Amt: Decimal; VAR PO_In_Amt: Decimal; VAR PO_Out_Amt: Decimal; VAR PO_Amt: Decimal; VAR PR_In_Qty: Decimal; VAR PR_Out_Qty: Decimal; VAR PR_Qty: Decimal; VAR PO_In_Qty: Decimal; VAR PO_Out_Qty: Decimal; VAR PO_Qty: Decimal; PostedInvNo: Code[20]; PostedInvLineNo: Integer)
    var
        NewGLBudgetEntry: Record "G/L Budget Entry";
        GLBudgetEntry: Record "G/L Budget Entry";
        GLBudgetEncPRPO: Record "WEH_G/L Budget Enc. PR/PO";
        PurchInvHead: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchHead: Record "Purchase Header";
        NewBudgetName: Code[10];
        LastEntryNo: Integer;
        LastEntryNoPRPO: Integer;
        RefGLBudgetEntryNo: Integer;
        CheckCriteria: Boolean;
    begin
        IF EntryType = EntryType::"Check Budget" THEN BEGIN
            CLEAR(CheckCriteria);
            CLEAR(LastEntryNo);
            CLEAR(GLBudgetEntry);
            GLBudgetEntry.SETCURRENTKEY("WEH_Ref. Document Type", "WEH_Ref. Document No.", "WEH_Ref. Document Line No.");
            GLBudgetEntry.SETRANGE("WEH_Ref. Document No.", PurchLine."Document No.");
            GLBudgetEntry.SETRANGE("WEH_Ref. Document Line No.", PurchLine."Line No.");
            GLBudgetEntry.SETRANGE("WEH_Ref. Document Type", GLBudgetEntry."WEH_Ref. Document Type"::Encumbrance);
            IF GLBudgetEntry.FindLast() THEN BEGIN
                IF GLBudgetEntry."WEH_Budget Type" <> PurchLine."WEH_Budget Type" THEN
                    CheckCriteria := TRUE;

                IF GLBudgetEntry."G/L Account No." <> PurchLine."No." THEN
                    CheckCriteria := TRUE;

                IF GLBudgetEntry.Date <> PurchLine."Order Date" THEN
                    CheckCriteria := TRUE;

                IF GLBudgetEntry."Budget Name" <> PurchLine."WEH_Budget Name" THEN
                    CheckCriteria := TRUE;

                IF GLBudgetEntry."Global Dimension 1 Code" <> PurchLine."Shortcut Dimension 1 Code" THEN
                    CheckCriteria := TRUE;

                IF GLBudgetEntry."Global Dimension 2 Code" <> PurchLine."Shortcut Dimension 2 Code" THEN
                    CheckCriteria := TRUE;

                IF GLBudgetEntry.Description <> PurchLine.Description THEN
                    CheckCriteria := TRUE;

                GLBudgetEntry.DELETE(TRUE);
            END ELSE
                CheckCriteria := TRUE;

            IF CheckCriteria THEN BEGIN
                CLEAR(LastEntryNo);
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY("Entry No.");
                IF GLBudgetEntry.FindLast() THEN
                    LastEntryNo := GLBudgetEntry."Entry No.";

                LastEntryNo += 1;

                CLEAR(GLBudgetEntry);
                GLBudgetEntry.INIT;
                GLBudgetEntry."Entry No." := LastEntryNo;
                GLBudgetEntry."Budget Name" := OldBudgetName;
                GLBudgetEntry."WEH_G/L Budget Name Type" := GLBudgetEntry."WEH_G/L Budget Name Type"::Encumbrance;
                GLBudgetEntry."G/L Account No." := GLAccNo;
                GLBudgetEntry.Date := PurchLine."Order Date";

                IF PurchHead.GET(PurchLine."Document Type", PurchLine."Document No.") THEN BEGIN
                    GLBudgetEntry."WEH_Document Posting Date" := PurchHead."Posting Date";

                    IF (PurchHead."Document Type" = PurchHead."Document Type"::Order) OR (PurchHead."Document Type" = PurchHead."Document Type"::Quote) THEN
                        GLBudgetEntry."WEH_Document Date" := PurchHead."Order Date"
                    ELSE
                        GLBudgetEntry."WEH_Document Date" := PurchHead."Document Date";
                END;
                GLBudgetEntry."Global Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code";
                GLBudgetEntry."Global Dimension 2 Code" := PurchLine."Shortcut Dimension 2 Code";
                GLBudgetEntry.Description := PurchLine.Description;
                GLBudgetEntry."User ID" := USERID;
                GLBudgetEntry."WEH_Budget Type" := PurchLine."WEH_Budget Type";
                GLBudgetEntry."WEH_Ref. Document Type" := GLBudgetEntry."WEH_Ref. Document Type"::Encumbrance;
                GLBudgetEntry."WEH_Ref. Document No." := PurchLine."Document No.";
                GLBudgetEntry."WEH_Ref. Document Line No." := PurchLine."Line No.";
                GLBudgetEntry.INSERT();
            END;
        END;

        CLEAR(LastEntryNoPRPO);
        CLEAR(GLBudgetEncPRPO);
        GLBudgetEncPRPO.SETCURRENTKEY(GLBudgetEncPRPO."Entry No.");
        IF GLBudgetEncPRPO.FindLast() THEN
            LastEntryNoPRPO := GLBudgetEncPRPO."Entry No.";

        CLEAR(RefGLBudgetEntryNo);
        RefGLBudgetEntryNo := FindRefGLBudgetEntry(PurchLine);

        LastEntryNoPRPO += 1;

        CLEAR(GLBudgetEncPRPO);
        GLBudgetEncPRPO.Init();
        GLBudgetEncPRPO."Entry No." := LastEntryNoPRPO;
        GLBudgetEncPRPO."G/L Budget Entry No." := RefGLBudgetEntryNo;
        GLBudgetEncPRPO."Entry Type" := EntryType;

        CLEAR(NewBudgetName);
        CLEAR(NewGLBudgetEntry);
        NewGLBudgetEntry.SETCURRENTKEY("Entry No.");
        NewGLBudgetEntry.SETRANGE("Entry No.", RefGLBudgetEntryNo);
        IF NewGLBudgetEntry.FindFirst() THEN
            NewBudgetName := NewGLBudgetEntry."Budget Name"
        ELSE
            NewBudgetName := OldBudgetName;

        GLBudgetEncPRPO."Budget Name" := NewBudgetName;
        GLBudgetEncPRPO."Posting Date" := PurchLine."Order Date";
        IF PurchHead.GET(PurchLine."Document Type", PurchLine."Document No.") THEN BEGIN
            GLBudgetEncPRPO."Document Posting Date" := PurchHead."Posting Date";

            IF (PurchHead."Document Type" = PurchHead."Document Type"::Order) OR (PurchHead."Document Type" = PurchHead."Document Type"::Quote) THEN
                GLBudgetEncPRPO."Document Date" := PurchHead."Order Date"
            ELSE
                GLBudgetEncPRPO."Document Date" := PurchHead."Document Date";
        END;

        GLBudgetEncPRPO."Ref. Document No." := PurchLine."Document No.";
        GLBudgetEncPRPO."Ref. Document Line No." := PurchLine."Line No.";

        GLBudgetEncPRPO."PR IN Amount" := PR_In_Amt;
        GLBudgetEncPRPO."PR OUT Amount" := PR_Out_Amt;
        GLBudgetEncPRPO."PR Amount" := PR_Amt;
        GLBudgetEncPRPO."PO IN Amount" := PO_In_Amt;
        GLBudgetEncPRPO."PO OUT Amount" := PO_Out_Amt;
        GLBudgetEncPRPO."PO Amount" := PO_Amt;

        GLBudgetEncPRPO."PR IN quantity" := PR_In_Qty;
        GLBudgetEncPRPO."PR OUT quantity" := PR_Out_Qty;
        GLBudgetEncPRPO."PR quantity" := PR_Qty;
        GLBudgetEncPRPO."PO IN quantity" := PO_In_Qty;
        GLBudgetEncPRPO."PO OUT quantity" := PO_Out_Qty;
        GLBudgetEncPRPO."PO quantity" := PO_Qty;

        GLBudgetEncPRPO."Posted Invoice No." := PostedInvNo;
        GLBudgetEncPRPO."Posted Invoice Line No." := PostedInvLineNo;

        CLEAR(PurchInvLine);
        PurchInvLine.SETCURRENTKEY("Document No.", "Line No.");
        PurchInvLine.SETRANGE("Document No.", PostedInvNo);
        PurchInvLine.SETRANGE("Line No.", PostedInvLineNo);
        IF PurchInvLine.FindFirst() THEN begin
            PurchInvHead.Get(PurchInvLine."Document No.");
            if PurchInvHead."Currency Code" = '' then
                GLBudgetEncPRPO."Actual Amount Exc. VAT" := PurchInvLine.Amount
            else
                GLBudgetEncPRPO."Actual Amount Exc. VAT" := round(PurchInvLine.Amount / PurchInvHead."Currency Factor", 0.01, '=');
        end;

        if PurchHead."Currency Code" <> '' then
            GLBudgetEncPRPO."Currency Factor" := PurchHead."Currency Factor";

        GLBudgetEncPRPO.Type := PurchLine.Type;
        GLBudgetEncPRPO."No." := PurchLine."No.";
        GLBudgetEncPRPO."Shortcut Dimension 1 Code" := PurchLine."Shortcut Dimension 1 Code";
        GLBudgetEncPRPO."Shortcut Dimension 2 Code" := PurchLine."Shortcut Dimension 2 Code";
        GLBudgetEncPRPO."Budget Type" := PurchLine."WEH_Budget Type";
        GLBudgetEncPRPO."User ID" := USERID;
        GLBudgetEncPRPO.INSERT();
    end;

    local procedure FindRefGLBudgetEntry(VAR PurchLine: Record "Purchase Line"): Integer
    var
        GLBudgetEntry: Record "G/L Budget Entry";
        RefGLBudgetEntry: Integer;
    begin
        CLEAR(RefGLBudgetEntry);
        IF PurchLine."Document Type" = PurchLine."Document Type"::Quote THEN BEGIN
            CLEAR(GLBudgetEntry);
            GLBudgetEntry.SETCURRENTKEY("WEH_Ref. Document Type", "WEH_Ref. Document No.", "WEH_Ref. Document Line No.");
            GLBudgetEntry.SETRANGE("WEH_Ref. Document No.", PurchLine."Document No.");
            GLBudgetEntry.SETRANGE("WEH_Ref. Document Line No.", PurchLine."Line No.");
            GLBudgetEntry.SETRANGE("WEH_Ref. Document Type", GLBudgetEntry."WEH_Ref. Document Type"::Encumbrance);
            IF GLBudgetEntry.FindLast() THEN
                RefGLBudgetEntry := GLBudgetEntry."Entry No.";
        END ELSE
            IF (PurchLine."Document Type" = PurchLine."Document Type"::Order) OR (PurchLine."Document Type" = PurchLine."Document Type"::Invoice) THEN BEGIN
                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY("WEH_Ref. Document Type", "WEH_Ref. Document No.", "WEH_Ref. Document Line No.");
                GLBudgetEntry.SETRANGE("WEH_Ref. Document Type", GLBudgetEntry."WEH_Ref. Document Type"::Encumbrance);
                GLBudgetEntry.SETRANGE("WEH_Ref. Document No.", PurchLine."AVTD_Ref. Doc. No.");
                GLBudgetEntry.SETRANGE("WEH_Ref. Document Line No.", PurchLine."AVTD_Ref. Line No.");
                IF GLBudgetEntry.FindLast() THEN
                    RefGLBudgetEntry := GLBudgetEntry."Entry No.";
            END;

        EXIT(RefGLBudgetEntry);
    end;

    procedure FindAmountPerDocument(VAR PurchHead: Record "Purchase Header"; var DocAmtTotal: Decimal)
    var
        PurchLine: Record "Purchase Line";
        //GLSetup: Record "General Ledger Setup";
        DocVATBase: Decimal;
        DocVATPercent: Decimal;
    begin
        //CLEAR(GLSetup);
        //GLSetup.GET();

        CLEAR(DocAmtTotal);
        CLEAR(DocVATBase);
        CLEAR(DocVATPercent);

        CLEAR(PurchLine);
        PurchLine.SETCURRENTKEY("Document Type", "Document No.");
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETRANGE("Document Type", PurchHead."Document Type");
        PurchLine.SETFILTER("No.", '<>%1', '');
        //PurchLine.SETFILTER("VAT %", '<>%1', 0);
        IF PurchLine.FindSet() THEN BEGIN
            REPEAT
                //DocAmtTotal += PurchLine."Line Amount";
                DocAmtTotal += PurchLine."Outstanding Amt. Ex. VAT (LCY)";
                DocVATBase += PurchLine."VAT Base Amount";
                IF PurchLine."VAT %" <> 0 THEN
                    DocVATPercent := PurchLine."VAT %"
            UNTIL PurchLine.NEXT() = 0;
        END;

        /*
        IF GLSetup."WEH_Budget Include VAT" THEN BEGIN
            IF NOT PurchHead."Prices Including VAT" THEN
                DocAmtTotal += ROUND(DocVATBase * DocVATPercent / 100);
        END ELSE BEGIN
            IF PurchHead."Prices Including VAT" THEN
                DocAmtTotal -= ROUND(DocVATBase * DocVATPercent / 100);
        END;
        */
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchHeaderDone', '', true, true)]
    local procedure InitPurchaseAssignedUserID(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromPurchaseHeader: Record "Purchase Header"; FromPurchRcptHeader: Record "Purch. Rcpt. Header"; FromPurchInvHeader: Record "Purch. Inv. Header"; ReturnShipmentHeader: Record "Return Shipment Header"; FromPurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; FromPurchaseHeaderArchive: Record "Purchase Header Archive")
    begin
        ToPurchaseHeader."WEH_Commit PO" := ToPurchaseHeader."WEH_Commit PO"::" ";
        ToPurchaseHeader."WEH_Check Budget" := ToPurchaseHeader."WEH_Check Budget"::" ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeInsertToPurchLine', '', true, true)]
    local procedure InitPurchaseLine(var ToPurchLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line"; FromDocType: Option; RecalcLines: Boolean; var ToPurchHeader: Record "Purchase Header"; DocLineNo: Integer; var NexLineNo: Integer)
    begin
        ToPurchLine."WEH_Check Budget" := ToPurchLine."WEH_Check Budget"::" ";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateTypeOnCopyFromTempPurchLine', '', true, true)]
    local procedure OnValidateTypeOnCopyFromTempPurchLine(var PurchLine: Record "Purchase Line"; TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        PurchLine."WEH_Budget Name" := TempPurchaseLine."WEH_Budget Name";
        PurchLine."WEH_Budget Type" := TempPurchaseLine."WEH_Budget Type";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateNoOnCopyFromTempPurchLine', '', true, true)]
    local procedure OnValidateNoOnCopyFromTempPurchLine(var PurchLine: Record "Purchase Line"; TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        PurchLine."WEH_Budget Name" := TempPurchaseLine."WEH_Budget Name";
        PurchLine."WEH_Budget Type" := TempPurchaseLine."WEH_Budget Type";
    end;

    /*
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeAssistEdit', '', true, true)]
    local procedure BudgetAssistEdit(var PurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[10];
    begin
        if PurchaseHeader."WEH_Budget Document Type" = PurchaseHeader."WEH_Budget Document Type"::Corporate then begin
            PurchSetup.Get();
            if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote then begin
                PurchSetup.TestField("WEH_PR Corp. Nos.");
                NoSeriesCode := PurchSetup."WEH_PR Corp. Nos.";
            end else begin
                PurchSetup.TestField("WEH_PO Corp. Nos.");
                NoSeriesCode := PurchSetup."WEH_PO Corp. Nos.";
            end;

            if NoSeriesMgt.SelectSeries(NoSeriesCode, OldPurchaseHeader."No. Series", PurchaseHeader."No. Series") then
                NoSeriesMgt.SetSeries(PurchaseHeader."No.");

            IsHandled := true;
        end;
    end;
    */

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeInitInsert', '', true, true)]
    local procedure OnBeforeInitInsert(var PurchaseHeader: Record "Purchase Header"; var xPurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: code[10];
    begin
        if PurchaseHeader."No." = '' then begin
            if PurchaseHeader."WEH_Budget Document Type" = PurchaseHeader."WEH_Budget Document Type"::Corporate then begin
                PurchSetup.Get();
                if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Quote then begin
                    PurchSetup.TestField("WEH_PR Corp. Nos.");
                    NoSeriesCode := PurchSetup."WEH_PR Corp. Nos.";
                end else
                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
                        PurchSetup.TestField("WEH_PO Corp. Nos.");
                        NoSeriesCode := PurchSetup."WEH_PO Corp. Nos.";
                    end;

                NoSeriesMgt.InitSeries(NoSeriesCode, xPurchaseHeader."No. Series", PurchaseHeader."Posting Date", PurchaseHeader."No.", PurchaseHeader."No. Series");

                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Post", 'OnAfterPurchInvLineInsert', '', true, true)]
    local procedure InitDeductPOBudget(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean)
    var
        POHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        Clear(PurchRcptLine);
        if PurchRcptLine.Get(PurchLine."Receipt No.", PurchLine."Receipt Line No.") then begin
            if POHeader.get(PurchLine."Document Type"::Order, PurchRcptLine."Order No.") then begin
                if POHeader."WEH_Budget Document Type" = POHeader."WEH_Budget Document Type"::Corporate then begin
                    if PurchaseLine.get(PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.") then begin
                        if PurchLine."WEH_Budget Type" in [PurchLine."WEH_Budget Type"::C, PurchLine."WEH_Budget Type"::O] then
                            DeductPOBudget(PurchaseLine, PurchInvLine."Document No.", PurchInvLine."Line No.", PurchRcptLine."Order No.", PurchRcptLine."Order Line No.");
                    end;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Post", 'OnAfterFinalizePosting', '', true, true)]
    local procedure AdjustBudgetEncumbrance(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    begin
        UpdateInvAmtBudget(PurchInvHeader);
        AdjustInvAmtBudget(PurchInvHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', true, true)]
    local procedure CustomSelect(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    var
        Selection: Integer;
        ReceiveOpt: Label '&Receive';
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            if PurchaseHeader."WEH_Budget Document Type" = PurchaseHeader."WEH_Budget Document Type"::Corporate then begin
                Selection := StrMenu(ReceiveOpt, 1);
                if Selection = 0 then
                    IsHandled := true;
                PurchaseHeader.Receive := Selection = 1;
                HideDialog := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchaseHeader', '', true, true)]
    local procedure InitCopyDocumentHeader(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header")
    begin
        ToPurchaseHeader.Status := ToPurchaseHeader.Status::Open;
        ToPurchaseHeader."WEH_Check Budget" := ToPurchaseHeader."WEH_Check Budget"::" ";
        ToPurchaseHeader."WEH_Finish PR" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnBeforeInsertToPurchLine', '', true, true)]
    local procedure InitCopyDocumentLine(var ToPurchLine: Record "Purchase Line"; FromPurchLine: Record "Purchase Line"; FromDocType: Option; RecalcLines: Boolean; var ToPurchHeader: Record "Purchase Header"; DocLineNo: Integer; var NexLineNo: Integer)
    begin
        ToPurchLine."WEH_Check Budget" := ToPurchLine."WEH_Check Budget"::" ";
        ToPurchLine."WEH_Finish PR" := false;
        ToPurchLine."AVTD_Ref. Doc. No." := '';
        ToPurchLine."AVTD_Ref. Line No." := 0;
    end;

    // Links
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', true, true)]
    local procedure AddBudgetAttachment(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        AddBudgetHead: Record "WEH_Add/T. Budget COR Header";
    begin
        case DocumentAttachment."Table ID" of
            DATABASE::"WEH_Add/T. Budget COR Header":
                begin
                    RecRef.Open(DATABASE::"WEH_Add/T. Budget COR Header");
                    if AddBudgetHead.Get(DocumentAttachment."No.") then
                        RecRef.GetTable(AddBudgetHead);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', true, true)]
    local procedure AddBudgetOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
        LineNo: Integer;
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnBeforeInsertAttachment', '', true, true)]
    local procedure AddBudgetInsertAttachment(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                begin
                    FieldRef := RecRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    // Send mail history
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mail Management", 'OnAfterSentViaSMTP', '', true, true)]
    procedure InsertEmailHistory(var MailSent: Boolean; var TempEmailItem: Record "Email Item"; var SMTPMail: Codeunit "SMTP Mail")
    var
        SendEmailHistory: Record "WEH_Send Email History";
        PurchOrder: Record "Purchase Header";
    begin
        if MailSent then begin
            if PurchOrder.get(PurchOrder."Document Type"::Order, TempEmailItem."WEH_Document No.") then begin
                SendEmailHistory.Init();
                SendEmailHistory."Entry No." := SendEmailHistory.LastEntryNo;
                SendEmailHistory."Document No." := TempEmailItem."WEH_Document No.";
                SendEmailHistory.Date := Today;
                SendEmailHistory.Time := Time;
                SendEmailHistory."Send to" := TempEmailItem."Send to";
                SendEmailHistory."Carbon Copy" := TempEmailItem."Send CC";
                SendEmailHistory."Assigned User ID" := UserId;
                SendEmailHistory."Document Entry No." := SendEmailHistory.DocNoLastEntryNo(TempEmailItem."WEH_Document No.");
                SendEmailHistory.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Document-Mailing", 'OnBeforeSendEmail', '', true, true)]
    procedure KeepRefDoc(var TempEmailItem: Record "Email Item"; var PostedDocNo: Code[20])
    begin
        TempEmailItem."WEH_Document No." := PostedDocNo;
    end;

    // Open link in mail
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    procedure OpenRecordOnPurchCrop(RecordRef: RecordRef; var PageID: Integer)
    var
        PurchHeader: Record "Purchase Header";
    begin
        case RecordRef.Number of
            DATABASE::"Purchase Header":
                begin
                    RecordRef.SetTable(PurchHeader);
                    if PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Quote] then begin
                        if PurchHeader."WEH_Budget Document Type" = PurchHeader."WEH_Budget Document Type"::Corporate then begin
                            case PurchHeader."Document Type" of
                                PurchHeader."Document Type"::Order:
                                    PageID := Page::"WEH_Purchase Order Corporate";
                                PurchHeader."Document Type"::Quote:
                                    PageID := Page::"WEH_Purch. Quote - Corporate";
                            end;
                        end;
                    end;
                end;
        end;
    end;

    procedure FinalPO(var PurchHead: Record "Purchase Header");
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        PurchLine: Record "Purchase Line";
        GLBudgetEntry: Record "G/L Budget Entry";
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        QtyRecNotInv: Decimal;
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
    begin
        PurchHead.TestField("AVTD_Purchase Status", PurchHead."AVTD_Purchase Status"::" ");

        if not Confirm('Do you want to final PO No. %1?', true, PurchHead."No.") then
            exit;

        Clear(PurchLine);
        PurchLine.SetCurrentKey("Document Type", "Document No.");
        PurchLine.SetRange("Document No.", PurchHead."No.");
        PurchLine.SetRange("Document Type", PurchHead."Document Type");
        PurchLine.SetFilter("Quantity Received", '<>%1', 0);
        if PurchLine.IsEmpty then
            Error('PO No. %1 is not received, please use cancel PO', PurchHead."No.");

        GLSetup.Get();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        Clear(QtyRecNotInv);
        Clear(PurchLine);
        PurchLine.SetCurrentKey("Document Type", "Document No.");
        PurchLine.SetRange("Document No.", PurchHead."No.");
        PurchLine.SetRange("Document Type", PurchHead."Document Type");
        if PurchLine.FindSet() then
            repeat
                if PurchLine."Quantity Received" <> PurchLine."Quantity Invoiced" then
                    Error('PO No. %1 Line No. %2 is not invoiced, unable to final PO', PurchLine."Document No.", PurchLine."Line No.");

                CLEAR(GLBudgetName);
                GLBudgetName.GET(PurchLine."WEH_Budget Name");
                GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                QtyRecNotInv += PurchLine."Qty. Rcd. Not Invoiced";

                PurchLine."AVTD_Purchase Status" := PurchLine."AVTD_Purchase Status"::"Final PO";

                PurchLine.Validate("Qty. to Receive", 0);
                PurchLine."Qty. to Receive (Base)" := 0;

                PurchLine."Outstanding Quantity" := 0;
                PurchLine."Outstanding Qty. (Base)" := 0;
                PurchLine."Qty. Rcd. Not Invoiced" := 0;

                PurchLine."Outstanding Amount" := 0;
                PurchLine."Outstanding Amount (LCY)" := 0;

                PurchLine.Validate("Qty. to Invoice", 0);
                PurchLine."Qty. to Invoice (Base)" := 0;
                PurchLine."Outstanding Amt. Ex. VAT (LCY)" := 0;

                PurchLine.Modify();

                CLEAR(GLBudgetEntry);
                GLBudgetEntry.SETCURRENTKEY("Entry No.");
                GLBudgetEntry.SETRANGE("WEH_Ref. Document No.", PurchLine."AVTD_Ref. Doc. No.");
                GLBudgetEntry.SETRANGE("WEH_Ref. Document Line No.", PurchLine."AVTD_Ref. Line No.");
                GLBudgetEntry.SETRANGE("WEH_Ref. Document Type", GLBudgetEntry."WEH_Ref. Document Type"::Encumbrance);
                IF GLBudgetEntry.FindFirst() THEN BEGIN
                    GLBudgetEntry.CALCFIELDS("WEH_Encumbrance PO Amount");
                    IF GLBudgetEntry."WEH_Encumbrance PO Amount" <> 0 THEN BEGIN
                        CLEAR(PRInLineAmt);
                        CLEAR(PROutLineAmt);
                        CLEAR(PRLineAmt);
                        CLEAR(POInLineAmt);
                        CLEAR(POOutLineAmt);
                        CLEAR(POLineAmt);
                        CLEAR(PRInLineQty);
                        CLEAR(PROutLineQty);
                        CLEAR(PRLineQty);
                        CLEAR(POInLineQty);
                        CLEAR(POOutLineQty);
                        CLEAR(POLineQty);
                        CLEAR(EntryType);

                        EntryType := EntryType::"Final PO";
                        POLineAmt := GLBudgetEntry."WEH_Encumbrance PO Amount" * (-1);

                        if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then
                            InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                                  PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                  PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                  '', 0)
                        else
                            if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C then
                                InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                                      PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                                      PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                                      '', 0);
                    end;
                end;
            until PurchLine.Next() = 0;

        PurchHead."AVTD_Purchase Status" := PurchHead."AVTD_Purchase Status"::"Final PO";
        PurchHead.AVTD_FINISHED := true;
        PurchHead.Modify();
    end;

    procedure CancelPO(var PurchHead: Record "Purchase Header");
    var
        PurchLine: Record "Purchase Line";
        Conf001: Label 'Do you want to cancel PO No. %1?';
        Err001: Label 'Please delete all lines before cancel.';
    begin
        PurchHead.TestField("WEH_Commit PO", PurchHead."WEH_Commit PO"::" ");

        if Confirm(Conf001, true, PurchHead."No.") then begin
            Clear(PurchLine);
            PurchLine.SetCurrentKey("Document Type", "Document No.");
            PurchLine.SetRange("Document No.", PurchHead."No.");
            PurchLine.SetRange("Document Type", PurchHead."Document Type");
            /*
            if PurchLine.FindSet() then
                repeat
                    if PurchLine."Quantity Received" <> 0 then
                        Error('PO %1 Line No. %2 Type %3 No. %4 already received. Cannot CANCEL PO, please use FINAL PO',
                              PurchLine."Document No.", PurchLine."Line No.", PurchLine.Type, PurchLine."No.");

                    PurchLine."AVTD_Purchase Status" := PurchLine."AVTD_Purchase Status"::Cancel;

                    PurchLine.Validate("Qty. to Receive", 0);
                    PurchLine."Qty. to Receive (Base)" := 0;

                    PurchLine."Outstanding Quantity" := 0;
                    PurchLine."Outstanding Qty. (Base)" := 0;
                    PurchLine."Qty. Rcd. Not Invoiced" := 0;

                    PurchLine."Outstanding Amount" := 0;
                    PurchLine."Outstanding Amount (LCY)" := 0;

                    PurchLine.Validate("Qty. to Invoice", 0);
                    PurchLine."Qty. to Invoice (Base)" := 0;
                    PurchLine."Outstanding Amt. Ex. VAT (LCY)" := 0;
                    PurchLine.Modify();
                until PurchLine.Next() = 0;
            */
            if not PurchLine.IsEmpty then
                Error(Err001);

            PurchHead."AVTD_Purchase Status" := PurchHead."AVTD_Purchase Status"::Cancel;
            PurchHead.AVTD_FINISHED := true;
            PurchHead.Modify();
        end;
    end;

    procedure UndoFinishPO(var PurchHead: Record "Purchase Header");
    var
        GLSetup: Record "General Ledger Setup";
        GLBudgetName: Record "G/L Budget Name";
        PurchLine: Record "Purchase Line";
        EntryType: Enum "WEH_Budget Enc. Entry Type";
        PRInLineAmt: Decimal;
        PROutLineAmt: Decimal;
        PRLineAmt: Decimal;
        POInLineAmt: Decimal;
        POOutLineAmt: Decimal;
        POLineAmt: Decimal;
        PRInLineQty: Decimal;
        PROutLineQty: Decimal;
        PRLineQty: Decimal;
        POInLineQty: Decimal;
        POOutLineQty: Decimal;
        POLineQty: Decimal;
    begin
        PurchHead.TestField("AVTD_Purchase Status", PurchHead."AVTD_Purchase Status"::"Final PO");

        if not Confirm('Do you want to undo finished PO No. %1?', true, PurchHead."No.") then
            exit;

        GLSetup.Get();
        GLSetup.TESTFIELD("WEH_G/L for Budget Type C");

        Clear(PurchLine);
        PurchLine.SetCurrentKey("Document Type", "Document No.");
        PurchLine.SetRange("Document Type", PurchHead."Document Type");
        PurchLine.SetRange("Document No.", PurchHead."No.");
        if PurchLine.FindSet() then
            repeat
                CLEAR(GLBudgetName);
                GLBudgetName.GET(PurchLine."WEH_Budget Name");
                GLBudgetName.TESTFIELD("WEH_Encumbrance Name");

                PurchLine."AVTD_Purchase Status" := PurchLine."AVTD_Purchase Status"::" ";
                PurchLine."Qty. to Receive" := PurchLine.Quantity - PurchLine."Quantity Received";
                PurchLine."Qty. to Receive (Base)" := PurchLine."Quantity (Base)" - PurchLine."Qty. Received (Base)";
                PurchLine."Qty. to Invoice" := PurchLine.Quantity - PurchLine."Quantity Invoiced";
                PurchLine."Qty. to Invoice (Base)" := PurchLine."Quantity (Base)" - PurchLine."Qty. Invoiced (Base)";
                PurchLine."Outstanding Quantity" := PurchLine.Quantity - PurchLine."Quantity Received";
                PurchLine."Outstanding Qty. (Base)" := PurchLine."Quantity (Base)" - PurchLine."Qty. Received (Base)";
                PurchLine.InitOutstandingAmount();
                PurchLine.Modify();

                CLEAR(PRInLineAmt);
                CLEAR(PROutLineAmt);
                CLEAR(PRLineAmt);
                CLEAR(POInLineAmt);
                CLEAR(POOutLineAmt);
                CLEAR(POLineAmt);
                CLEAR(PRInLineQty);
                CLEAR(PROutLineQty);
                CLEAR(PRLineQty);
                CLEAR(POInLineQty);
                CLEAR(POOutLineQty);
                CLEAR(POLineQty);
                CLEAR(EntryType);

                EntryType := EntryType::"Un-Final PO";
                POLineAmt := PurchLine."Outstanding Amt. Ex. VAT (LCY)";

                if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::O then
                    InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                          PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                          PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                          '', 0)
                else
                    if PurchLine."WEH_Budget Type" = PurchLine."WEH_Budget Type"::C then
                        InitBudgetEncumbrance(PurchLine, EntryType, PurchLine."No.", GLBudgetName."WEH_Encumbrance Name",
                                              PRInLineAmt, PROutLineAmt, PRLineAmt, POInLineAmt, POOutLineAmt, POLineAmt,
                                              PRInLineQty, PROutLineQty, PRLineQty, POInLineQty, POOutLineQty, POLineQty,
                                              '', 0);
            until PurchLine.Next() = 0;

        PurchHead.AVTD_FINISHED := false;
        PurchHead."AVTD_Purchase Status" := PurchHead."AVTD_Purchase Status"::" ";
        PurchHead.Modify();
    end;

    var
        ReleasePurchDoc: Codeunit "Release Purchase Document";

    // Workflow
    [IntegrationEvent(false, false)]
    PROCEDURE OnSendBudgetforApproval(VAR BudgetCORHeader: Record "WEH_Add/T. Budget COR Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    PROCEDURE OnCancelBudgetforApproval(VAR BudgetCORHeader: Record "WEH_Add/T. Budget COR Header");
    begin
    end;

    procedure CheckWorkflowBudgetEnabled(var BudgetCORHeader: Record "WEH_Add/T. Budget COR Header"): Boolean
    var
        WFMngt: Codeunit "Workflow Management";
        WFBudget: Codeunit "WEH_Budget Workflow Mgt.";
        NoWorkflowEnb: Label 'No approval workflow for this record type is enabled.';
    begin
        if not WFMngt.CanExecuteWorkflow(BudgetCORHeader, WFBudget.RunWorkflowOnSendBudgetApprovalCode()) then
            Error(NoWorkflowEnb);
        exit(true);
    end;
}
