Report 50101 "Logico VAT Draft Invoice"
{
    Caption = 'Draft Invoice';
    UsageCategory = ReportsAndAnalysis;
    WordLayout = './Layouts/Logico VAT Draft Invoice.docx';
    DefaultLayout = Word;

    dataset
    {
        dataitem(Header; "Sales Header")
        {
            CalcFields = "Amount Including VAT", Amount;
            DataItemTableView = sorting("No.") where("Document Type" = const(Invoice));
            RequestFilterFields = "No.", "Posting Date";
            column(ReportForNavId_2; 2) { }
            column(ReportForNav_Header; ReportForNavWriteDataItem('Header', Header)) { }
            column(HasDiscount; ForNAVCheckDocumentDiscount.HasDiscount(Header))
            {
                IncludeCaption = false;
            }
            dataitem(Line; "Sales Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = Header;
                DataItemTableView = sorting("Document No.", "Line No.");
                column(ReportForNavId_3; 3) { }
                column(ReportForNav_Line; ReportForNavWriteDataItem('Line', Line)) { }
            }
            dataitem(VATAmountLine; "VAT Amount Line")
            {
                DataItemTableView = sorting("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", Positive);
                UseTemporary = true;
                column(ReportForNavId_1000000001; 1000000001) { }
                column(ReportForNav_VATAmountLine; ReportForNavWriteDataItem('VATAmountLine', VATAmountLine)) { }
                trigger OnPreDataItem();
                begin
                    if not PrintVATAmountLines then
                        CurrReport.Break;
                end;

            }
            dataitem(VATClause; "VAT Clause")
            {
                DataItemTableView = sorting(Code);
                UseTemporary = true;
                column(ReportForNavId_1000000002; 1000000002) { }
                column(ReportForNav_VATClause; ReportForNavWriteDataItem('VATClause', VATClause)) { }
            }
            trigger OnAfterGetRecord();
            begin

                ChangeLanguage("Language Code");
                GetVatAmountLines;
                GetVATClauses;
                UpdateNoPrinted;
            end;

        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = Basic;
                        Caption = 'No. of Copies';
                    }
                    field(ForNavOpenDesigner; ReportForNavOpenDesigner)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Design';
                        Visible = ReportForNavAllowDesign;
                    }
                }
            }
        }

        actions
        {
        }
    }

    trigger OnInitReport()
    begin
        ;
        ReportsForNavInit;
        Codeunit.Run(Codeunit::"ForNAV First Time Setup");
    end;

    trigger OnPostReport()
    begin
    end;

    trigger OnPreReport()
    begin
        ;
        ReportsForNavPre;
        ReportForNav.SetCopies('Header', NoOfCopies);
        LoadWatermark;
    end;

    var
        ForNAVCheckDocumentDiscount: Codeunit "ForNAV Check Document Discount";
        NoOfCopies: Integer;

    local procedure ChangeLanguage(LanguageCode: Code[10])
    var
        ForNAVSetup: Record "ForNAV Setup";
        Language: Record Language;
    begin
        ForNAVSetup.Get;
        if ForNAVSetup."Inherit Language Code" then
            CurrReport.Language(Language.GetLanguageID(LanguageCode));
    end;

    local procedure GetVatAmountLines()
    var
        ForNAVGetVatAmountLines: Codeunit "ForNAV Get Vat Amount Lines";
    begin
        VATAmountLine.DeleteAll;
        ForNAVGetVatAmountLines.GetVatAmountLines(Header, VATAmountLine);
    end;

    local procedure GetVATClauses()
    var
        ForNAVGetVatClause: Codeunit "ForNAV Get Vat Clause";
    begin
        VATClause.DeleteAll;
        ForNAVGetVatClause.GetVATClauses(VATAmountLine, VATClause, Header."Language Code");
    end;

    local procedure PrintVATAmountLines(): Boolean
    var
        ForNAVSetup: Record "ForNAV Setup";
    begin
        with ForNAVSetup do begin
            Get;
            case "VAT Report Type" of
                "vat report type"::Always:
                    exit(true);
                "vat report type"::"Multiple Lines":
                    exit(VATAmountLine.Count > 1);
                "vat report type"::Never:
                    exit(false);
            end;
        end;
    end;

    local procedure UpdateNoPrinted()
    var
        ForNAVUpdateNoPrinted: Codeunit "ForNAV Update No. Printed";
    begin
        ForNAVUpdateNoPrinted.UpdateNoPrinted(Header, CurrReport.Preview);
    end;

    local procedure GetNoOfCopies(): Integer
    var
        GetNoofCopies: Codeunit "ForNAV Get No. of Copies";
    begin
        exit(NoOfCopies + GetNoofCopies.GetNoOfCopies(Header));
    end;

    local procedure LoadWatermark()
    var
        ForNAVSetup: Record "ForNAV Setup";
        OutStream: OutStream;
    begin
        with ForNAVSetup do begin
            Get;
            if not PrintLogo(ForNAVSetup) then
                exit;
            CalcFields("Document Watermark");
            if not "Document Watermark".Hasvalue then
                exit;

            ReportForNav.LoadWatermarkImage(ForNAVSetup.GetDocumentWatermark);
        end;
    end;

    procedure PrintLogo(ForNAVSetup: Record "ForNAV Setup"): Boolean
    begin
        if not ForNAVSetup."Use Preprinted Paper" then
            exit(true);
        if 'Pdf' = 'PDF' then
            exit(true);
        if 'Pdf' = 'Preview' then
            exit(true);
        exit(false);
    end;

    // --> Reports ForNAV Autogenerated code - do not delete or modify
    var
        ReportForNavInitialized: Boolean;
        ReportForNavShowOutput: Boolean;
        ReportForNavTotalsCausedBy: Boolean;
        ReportForNavOpenDesigner: Boolean;
        [InDataSet]
        ReportForNavAllowDesign: Boolean;
        ReportForNav: Codeunit "ForNAV Report Management";

    local procedure ReportsForNavInit()
    var
        id: Integer;
    begin
        Evaluate(id, CopyStr(CurrReport.ObjectId(false), StrPos(CurrReport.ObjectId(false), ' ') + 1));
        ReportForNav.OnInit(id, ReportForNavAllowDesign);
    end;

    local procedure ReportsForNavPre()
    begin
        if ReportForNav.LaunchDesigner(ReportForNavOpenDesigner) then CurrReport.Quit();
    end;

    local procedure ReportForNavSetTotalsCausedBy(value: Boolean)
    begin
        ReportForNavTotalsCausedBy := value;
    end;

    local procedure ReportForNavSetShowOutput(value: Boolean)
    begin
        ReportForNavShowOutput := value;
    end;

    local procedure ReportForNavInit(jsonObject: JsonObject)
    begin
        ReportForNav.Init(jsonObject, CurrReport.ObjectId);
    end;

    local procedure ReportForNavWriteDataItem(dataItemId: Text; rec: Variant): Text
    var
        values: Text;
        jsonObject: JsonObject;
        currLanguage: Integer;
    begin
        if not ReportForNavInitialized then begin
            ReportForNavInit(jsonObject);
            ReportForNavInitialized := true;
        end;

        case (dataItemId) of
        end;
        ReportForNav.AddDataItemValues(jsonObject, dataItemId, rec);
        jsonObject.WriteTo(values);
        exit(values);
    end;
    // Reports ForNAV Autogenerated code - do not delete or modify -->
}
