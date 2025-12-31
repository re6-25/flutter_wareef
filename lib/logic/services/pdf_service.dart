import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:wareef_academy/data/models/app_models.dart';

class PdfService {
  static Future<void> generateProjectsReport(List<ProjectModel> projects) async {
    final pdf = pw.Document();
    
    // Arabic font support in PDF is tricky, let's use a standard font for now
    // or we can try to load a font from assets if provided. 
    // Since we don't have local assets yet, we'll use a network font or internal fallback.
    final font = await PdfGoogleFonts.cairoRegular();

    pdf.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Wareef Academy - Projects Report', style: pw.TextStyle(fontSize: 24))),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Title', 'Description', 'Status'],
            data: projects.map((p) => [p.title, p.description, p.status]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerRight,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
