pageextension 51009 "WEH_Purchase Order List BGC" extends "Purchase Order List"
{
    actions
    {
        addafter(PostedPurchaseInvoices)
        {
            action("WEH_Send Email History")
            {
                Image = Email;
                Promoted = true;
                Caption = 'Send Email History';
                PromotedCategory = Category9;
                ApplicationArea = ALL;

                trigger OnAction()
                var
                    SendEmailHistory: Record "WEH_Send Email History";
                    PageSendEmailHistory: Page "WEH_Send Email History";
                begin
                    Clear(SendEmailHistory);
                    SendEmailHistory.Reset();
                    SendEmailHistory.FilterGroup(2);
                    SendEmailHistory.SetRange("Document No.", "No.");
                    SendEmailHistory.FilterGroup(0);
                    PageSendEmailHistory.SetTableView(SendEmailHistory);
                    PageSendEmailHistory.Run();
                end;
            }
        }
    }
}
