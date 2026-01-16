import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/workplace.dart';
import '../models/certificate.dart';

Future<void> downloadCertificatePdf(
  context,
  Workplace workplace,
  Certificate cert,
) async {
  final pdf = pw.Document();
  final issueDate = cert.issueDate;
  final expiryDate = cert.expiryDate;
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(32),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColor.fromInt(0xFF1976D2),
              width: 3,
            ),
            borderRadius: pw.BorderRadius.circular(24),
          ),
          width: 420,
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Placeholder for logo
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE3E3E3),
                  shape: pw.BoxShape.circle,
                ),
                alignment: pw.Alignment.center,
                child: pw.Text('LOGO', style: pw.TextStyle(fontSize: 18, color: PdfColor.fromInt(0xFF1976D2))),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Certificate of Registration',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF1976D2),
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'This is to certify that',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                workplace.name,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Registration No: ${workplace.registrationNumber}',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Category: ${workplace.category.name}',
                style: pw.TextStyle(fontSize: 15),
              ),
              pw.SizedBox(height: 18),
              pw.Divider(),
              pw.Text(
                cert.type == CertificateType.factory
                    ? 'Factory Certificate'
                    : 'Health & Safety Certificate',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF3F51B5),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Certificate No: ${cert.certificateNumber}',
                style: pw.TextStyle(fontSize: 15),
              ),
              pw.Text(
                'Issued: ${issueDate.day.toString().padLeft(2, '0')}/${issueDate.month.toString().padLeft(2, '0')}/${issueDate.year}',
                style: pw.TextStyle(fontSize: 15),
              ),
              pw.Text(
                'Expires: ${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}',
                style: pw.TextStyle(
                  fontSize: 15,
                  color: cert.isExpired
                      ? PdfColor.fromInt(0xFFD32F2F)
                      : PdfColor.fromInt(0xFF388E3C),
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(fontSize: 13),
                      ),
                      pw.Container(
                        width: 120,
                        height: 32,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColor.fromInt(0xFF1976D2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date', style: pw.TextStyle(fontSize: 13)),
                      pw.Container(
                        width: 80,
                        height: 32,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColor.fromInt(0xFF1976D2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'This certificate is valid only if digitally verified.',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  final pdfBytes = await pdf.save();
  await Printing.sharePdf(
    bytes: pdfBytes,
    filename: 'certificate_${workplace.registrationNumber}.pdf',
  );
}
