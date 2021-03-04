page 50081 "WEH_Add Budget List CORP"
{
    Caption = 'Add Budget List - Corporate';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WEH_Add/T. Budget COR Header";
    SourceTableView = SORTING("No.") WHERE("Document Type" = CONST("Add Budget"), Status = CONST(" "));
    CardPageId = "WEH_Add Budget Order CORP";
    Editable = false;
    PromotedActionCategories = 'New,Process,Reports,Approve,Post';
    //PromotedActionCategoriesML = ENU=New,Process,Reports,Functions,Prints,Posting;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Approve Status"; "Approve Status")
                {
                    ApplicationArea = all;
                }
                field("Requested by"; "Requested by")
                {
                    ApplicationArea = All;
                }
                field("Requested Name"; "Requested Name")
                {
                    ApplicationArea = All;
                }
                field(Remark; Remark)
                {
                    ApplicationArea = All;
                }
                field("Remark 2"; "Remark 2")
                {
                    ApplicationArea = All;
                }
                field("Post to Budget"; "Post to Budget")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            /*
            action("Approve Add Budget")
            {
                Caption = 'Approve Add Budget';
                ApplicationArea = All;
                Image = Approve;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatusApprove(2);
                end;
            }
            action("Undo Approved Add Budget")
            {
                Caption = 'Undo Approved Add Budget';
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatusApprove(0);
                end;
            }
            action("Reject Add Budget")
            {
                Caption = 'Reject Add Budget';
                ApplicationArea = All;
                Image = Reject;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatusApprove(3);
                end;
            }
            action("Send Approve Add Budget")
            {
                Caption = 'Send Request Approve Add Budget';
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatusApprove(1);
                end;
            }
            action("Cancel Request Add Budget")
            {
                Caption = 'Cancel Request Add Budget';
                ApplicationArea = All;
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatusApprove(4);
                end;
            }
            */
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    PosttoGLBudgetEntry();
                end;
            }
        }
    }
}
