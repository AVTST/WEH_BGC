codeunit 50008 "WEH_Budget Workflow Mgt."
{
    var
        WFMngt: Codeunit "Workflow Management";
        AppMgmt: Codeunit "Approvals Mgmt.";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        SendBudgetReq: Label 'Approval Request for Budget Control is requested';
        AppReqBudget: Label 'Approval Request for Budget Control is approved';
        RejReqBudget: Label 'Approval Request for Budget Control is rejected';
        DelReqBudget: Label 'Approval Request for Budget Control is delegated';
        CancelAppBudget: Label 'Approval Request for Budget Control is Canceled';

    procedure RunWorkflowOnCancelBudgetApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelBudgetApproval'))
    end;

    procedure RunWorkflowOnSendBudgetApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendBudgetApproval'))
    end;

    procedure RunWorkflowOnApproveBudgetApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnApproveBudgetApproval'))
    end;

    procedure RunWorkflowOnRejectBudgetApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnRejectBudgetApproval'))
    end;

    procedure RunWorkflowOnDelegateBudgetApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnDelegateBudgetApproval'))
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WEH_Budget Control Management", 'OnSendBudgetforApproval', '', false, false)]
    procedure RunWorkflowOnSendPurchBudgetApproval(var BudgetCORHeader: Record "WEH_Add/T. Budget COR Header")
    begin
        WFMngt.HandleEvent(RunWorkflowOnSendBudgetApprovalCode(), BudgetCORHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WEH_Budget Control Management", 'OnCancelBudgetforApproval', '', false, false)]
    procedure RunWorkflowOnCancelPurchBudgetApproval(var BudgetCORHeader: Record "WEH_Add/T. Budget COR Header")
    begin
        WFMngt.HandleEvent(RunWorkflowOnCancelBudgetApprovalCode(), BudgetCORHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', false, false)]
    procedure RunWorkflowOnApprovePurchBudgetApproval(var ApprovalEntry: Record "Approval Entry")
    begin
        WFMngt.HandleEventOnKnownWorkflowInstance(RunWorkflowOnApproveBudgetApprovalCode(), ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    procedure RunWorkflowOnRejectBudgetApproval(var ApprovalEntry: Record "Approval Entry")
    begin
        WFMngt.HandleEventOnKnownWorkflowInstance(RunWorkflowOnRejectBudgetApprovalCode(), ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnDelegateApprovalRequest', '', false, false)]
    procedure RunWorkflowOnDelegateBudgetApproval(var ApprovalEntry: Record "Approval Entry")
    begin
        WFMngt.HandleEventOnKnownWorkflowInstance(RunWorkflowOnDelegateBudgetApprovalCode(), ApprovalEntry, ApprovalEntry."Workflow Step Instance ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                BEGIN
                    RecRef.SETTABLE(BudgetCORHeader);
                    BudgetCORHeader.VALIDATE("Approve Status", BudgetCORHeader."Approve Status"::Approved);
                    BudgetCORHeader.MODIFY(TRUE);
                    Handled := true;
                END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                BEGIN
                    RecRef.SETTABLE(BudgetCORHeader);
                    BudgetCORHeader.VALIDATE("Approve Status", BudgetCORHeader."Approve Status"::" ");
                    BudgetCORHeader.MODIFY(TRUE);
                    Handled := true;
                END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    procedure SetStatusToPendingApproval(var Variant: Variant; RecRef: RecordRef; var IsHandled: Boolean)
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                BEGIN
                    RecRef.SETTABLE(BudgetCORHeader);
                    BudgetCORHeader.VALIDATE("Approve Status", BudgetCORHeader."Approve Status"::"Pending Approval");
                    BudgetCORHeader.MODIFY(TRUE);
                    IsHandled := true;
                END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    procedure AddEventToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendBudgetApprovalCode(), Database::"WEH_Add/T. Budget COR Header", SendBudgetReq, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnApproveBudgetApprovalCode(), Database::"Approval Entry", AppReqBudget, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnRejectBudgetApprovalCode(), Database::"Approval Entry", RejReqBudget, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnDelegateBudgetApprovalCode(), Database::"Approval Entry", DelReqBudget, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelBudgetApprovalCode(), Database::"WEH_Add/T. Budget COR Header", CancelAppBudget, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    procedure InsertAppEntry(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry")
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"WEH_Add/T. Budget COR Header":
                BEGIN
                    RecRef.SetTable(BudgetCORHeader);
                    ApprovalEntryArgument."Document No." := BudgetCORHeader."No.";
                    case BudgetCORHeader."Document Type" of
                        BudgetCORHeader."Document Type"::"Transfer Budget":
                            begin
                                ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::"TRANS. BUDGET ORDER - CORP.";
                                BudgetCORHeader.CalcFields("Transfer Amount");
                                ApprovalEntryArgument.Amount := BudgetCORHeader."Transfer Amount";
                                ApprovalEntryArgument."Amount (LCY)" := BudgetCORHeader."Transfer Amount";
                            end;
                        BudgetCORHeader."Document Type"::"Add Budget":
                            begin
                                ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::"ADD BUDGET ORDER - CORP.";
                                BudgetCORHeader.CalcFields("Add Amount");
                                ApprovalEntryArgument.Amount := BudgetCORHeader."Add Amount";
                                ApprovalEntryArgument."Amount (LCY)" := BudgetCORHeader."Add Amount";
                            end;
                    end;
                END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    procedure OpenRecordOnBudgetControl(RecordRef: RecordRef; var PageID: Integer)
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
    begin
        case RecordRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                begin
                    RecordRef.SetTable(BudgetCORHeader);
                    if BudgetCORHeader."Document Type" = BudgetCORHeader."Document Type"::"Transfer Budget" then
                        PageID := Page::"WEH_Transfer Budget Order CORP";
                    if BudgetCORHeader."Document Type" = BudgetCORHeader."Document Type"::"Add Budget" then
                        PageID := Page::"WEH_Add Budget Order CORP";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Report, report::"Notification Email", 'OnSetReportFieldPlaceholders', '', true, true)]
    procedure InitVarNotiEmail(RecRef: RecordRef; var Field1Label: Text; var Field1Value: Text; var Field2Label: Text; var Field2Value: Text; var Field3Label: Text; var Field3Value: Text)
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                begin
                    RecRef.SetTable(BudgetCORHeader);
                    BudgetCORHeader.CalcFields("Add Amount", "Transfer Amount");
                    case BudgetCORHeader."Document Type" of
                        BudgetCORHeader."Document Type"::"Transfer Budget":
                            begin
                                Field1Label := 'Transfer Budget Amount';
                                Field1Value := format(BudgetCORHeader."Transfer Amount");
                            end;
                        BudgetCORHeader."Document Type"::"Add Budget":
                            begin
                                Field1Label := 'Add Budget Amount';
                                Field1Value := format(BudgetCORHeader."Add Amount");
                            end;
                    end;
                    Field2Label := 'Requested by';
                    Field2Value := BudgetCORHeader."Requested by";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Report, report::"Notification Email", 'OnBeforeGetDocumentTypeAndNumber', '', true, true)]
    procedure InitVarNotiEmail2(var NotificationEntry: Record "Notification Entry"; var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        BudgetCORHeader: Record "WEH_Add/T. Budget COR Header";
        FieldRef: FieldRef;
    begin
        case RecRef.Number of
            DATABASE::"WEH_Add/T. Budget COR Header":
                begin
                    RecRef.SetTable(BudgetCORHeader);
                    case BudgetCORHeader."Document Type" of
                        BudgetCORHeader."Document Type"::"Transfer Budget":
                            DocumentType := 'TRANSFER BUDGET ORDER - CORPORATE : ';
                        BudgetCORHeader."Document Type"::"Add Budget":
                            DocumentType := 'ADD BUDGET ORDER - CORPORATE : ';
                    end;
                    FieldRef := RecRef.FIELD(1);
                    DocumentNo := FORMAT(FieldRef.VALUE);
                    IsHandled := true;
                end;
        end;
    end;
}
