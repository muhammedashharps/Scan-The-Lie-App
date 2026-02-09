import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/product.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateAndDownload(Product product) async {
    final pdf = pw.Document();

    // Theme Colors
    const primaryColor = PdfColors.indigo900;
    const accentColor = PdfColors.indigo50;

    // Fonts & Styles
    final titleStyle = pw.TextStyle(
        fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
    final sectionTitleStyle = pw.TextStyle(
        fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor);
    final headerStyle = pw.TextStyle(
        fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white);
    const contentStyle =
        pw.TextStyle(fontSize: 9, color: PdfColors.black);

    // Load Image
    pw.ImageProvider? scannedImage;
    if (product.imagePath != null && File(product.imagePath!).existsSync()) {
      final imageBytes = await File(product.imagePath!).readAsBytes();
      scannedImage = pw.MemoryImage(imageBytes);
    }

    pdf.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return [
              // HEADER BANNER
              pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 40, vertical: 30),
                  color: primaryColor,
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('SCAN THE LIE', style: titleStyle),
                            pw.Text('Detailed Analysis Report',
                                style: contentStyle.copyWith(
                                    color: PdfColors.grey300)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                                'DATE: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                style: contentStyle.copyWith(
                                    color: PdfColors.white)),
                            pw.Text(
                                'TIME: ${DateFormat('hh:mm a').format(DateTime.now())}',
                                style: contentStyle.copyWith(
                                    color: PdfColors.white)),
                          ],
                        )
                      ])),

              pw.Container(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // PRODUCT & IMAGE SECTION
                        pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Product Info
                              pw.Expanded(
                                flex: 3,
                                child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('PRODUCT IDENTIFICATION',
                                          style: sectionTitleStyle),
                                      pw.Container(
                                          height: 2,
                                          width: 100,
                                          color: primaryColor,
                                          margin: const pw.EdgeInsets.only(
                                              top: 4, bottom: 8)),
                                      pw.Text(product.name,
                                          style: pw.TextStyle(
                                              fontSize: 18,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 10),
                                      if (product.nutritionFacts != null) ...[
                                        _buildInfoRow(
                                            'Serving Size',
                                            product.nutritionFacts
                                                    ?.servingSize ??
                                                'N/A'),
                                        _buildInfoRow('Calories',
                                            '${product.nutritionFacts?.calories ?? 0}'),
                                      ]
                                    ]),
                              ),
                              pw.SizedBox(width: 20),
                              // Scanned Image
                              if (scannedImage != null)
                                pw.Container(
                                  width: 120,
                                  height: 120,
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.grey400),
                                    borderRadius: pw.BorderRadius.circular(8),
                                  ),
                                  child: pw.ClipRRect(
                                    horizontalRadius: 8,
                                    verticalRadius: 8,
                                    child: pw.Image(scannedImage,
                                        fit: pw.BoxFit.cover),
                                  ),
                                ),
                            ]),

                        pw.SizedBox(height: 30),

                        // PERSONAL ANALYSIS SECTION
                        if (product.personalAnalysis != null) ...[
                          pw.Container(
                              padding: const pw.EdgeInsets.all(15),
                              decoration: pw.BoxDecoration(
                                  color: accentColor,
                                  borderRadius: pw.BorderRadius.circular(8),
                                  border: pw.Border.all(
                                      color: PdfColors.indigo100)),
                              child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(children: [
                                      pw.Text('PERSONAL COMPATIBILITY: ',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 10)),
                                      pw.Text(
                                          product
                                              .personalAnalysis!.compatibility
                                              .toUpperCase(),
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 10,
                                              color: _getCompatibilityColor(
                                                  product.personalAnalysis!
                                                      .compatibility))),
                                    ]),
                                    pw.SizedBox(height: 10),

                                    // Health Considerations
                                    if (product.personalAnalysis!
                                        .healthConsiderations.isNotEmpty) ...[
                                      pw.Text('HEALTH CONSIDERATIONS:',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 10)),
                                      pw.SizedBox(height: 5),
                                      ...product.personalAnalysis!
                                          .healthConsiderations
                                          .map((h) => pw.Bullet(
                                              text:
                                                  '${h.title}: ${h.description}',
                                              style: contentStyle)),
                                      pw.SizedBox(height: 10),
                                    ],

                                    pw.Text('RECOMMENDATIONS:',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10)),
                                    pw.SizedBox(height: 5),
                                    ...product.personalAnalysis!.recommendations
                                        .map((r) => pw.Bullet(
                                            text: r, style: contentStyle)),
                                  ])),
                          pw.SizedBox(height: 30),
                        ],

                        // INGREDIENT SECTION
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('INGREDIENT ANALYSIS',
                                style: sectionTitleStyle),
                            pw.Container(
                                height: 2,
                                width: 100,
                                color: primaryColor,
                                margin: const pw.EdgeInsets.only(
                                    top: 4, bottom: 8)),
                            pw.Table(
                                border: pw.TableBorder.all(
                                    color: PdfColors.grey300),
                                children: [
                                  // Header
                                  pw.TableRow(
                                      decoration:
                                          const pw.BoxDecoration(color: primaryColor),
                                      children: [
                                        _buildCell('INGREDIENT', headerStyle),
                                        _buildCell('PURPOSE', headerStyle),
                                        _buildCell('RISK', headerStyle),
                                        _buildCell('CONTROVERSY', headerStyle),
                                      ]),
                                  // Rows
                                  ...product.ingredients.map((ing) {
                                    return pw.TableRow(
                                        decoration: pw.BoxDecoration(
                                            color: product.ingredients
                                                            .indexOf(ing) %
                                                        2 ==
                                                    0
                                                ? PdfColors.white
                                                : accentColor),
                                        children: [
                                          _buildCell(ing.name, contentStyle),
                                          _buildCell(ing.purpose, contentStyle),
                                          _buildCell(
                                              ing.riskLevel.toUpperCase(),
                                              contentStyle.copyWith(
                                                  color: _getRiskColor(
                                                      ing.riskLevel),
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                          _buildCell(
                                              ing.controversy, contentStyle),
                                        ]);
                                  }),
                                ]),
                          ],
                        ),

                        pw.SizedBox(height: 30),

                        // CLAIMS SECTION
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('CLAIMS VERIFICATION',
                                style: sectionTitleStyle),
                            pw.Container(
                                height: 2,
                                width: 100,
                                color: primaryColor,
                                margin: const pw.EdgeInsets.only(
                                    top: 4, bottom: 8)),
                            pw.Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children:
                                    product.claimVerifications.map((claim) {
                                  return pw.Container(
                                      width: 230,
                                      padding: const pw.EdgeInsets.all(10),
                                      decoration: pw.BoxDecoration(
                                        borderRadius:
                                            pw.BorderRadius.circular(6),
                                        border: pw.Border.all(
                                            color: PdfColors.grey300),
                                      ),
                                      child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Row(
                                                mainAxisAlignment: pw
                                                    .MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  pw.Expanded(
                                                      child: pw.Text(
                                                          claim.claim,
                                                          style: pw.TextStyle(
                                                              fontWeight: pw
                                                                  .FontWeight
                                                                  .bold,
                                                              fontSize: 9),
                                                          maxLines: 2)),
                                                  pw.Text(
                                                      claim.verdict
                                                          .toUpperCase(),
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight.bold,
                                                          fontSize: 10,
                                                          color: _getVerdictColor(
                                                              claim.verdict))),
                                                ]),
                                            pw.SizedBox(height: 4),
                                            pw.Text(claim.explanation,
                                                style: contentStyle.copyWith(
                                                    fontSize: 8,
                                                    color: PdfColors.grey700),
                                                maxLines: 4),
                                          ]));
                                }).toList()),
                          ],
                        ),
                      ])),
            ];
          },
          footer: (context) {
            return pw.Container(
                alignment: pw.Alignment.centerRight,
                margin:
                    const pw.EdgeInsets.only(top: 20, right: 40, bottom: 20),
                child: pw.Text('Generated by Scan The Lie Powered by Gemini AI',
                    style: const pw.TextStyle(
                        color: PdfColors.grey500, fontSize: 8)));
          }),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Report_${product.name}.pdf',
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(children: [
          pw.Text('$label: ',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ]));
  }

  pw.Widget _buildCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: style),
    );
  }

  PdfColor _getRiskColor(String level) {
    if (level.toLowerCase() == 'high') return PdfColors.red700;
    if (level.toLowerCase() == 'moderate') return PdfColors.orange700;
    return PdfColors.green700;
  }

  PdfColor _getCompatibilityColor(String level) {
    if (level.toLowerCase() == 'low') return PdfColors.red700;
    if (level.toLowerCase() == 'medium') return PdfColors.orange700;
    return PdfColors.green700;
  }

  PdfColor _getVerdictColor(String verdict) {
    final v = verdict.toLowerCase();
    if (v == 'true' || v == 'verified') return PdfColors.green700;
    if (v == 'misleading') return PdfColors.orange700;
    return PdfColors.red700;
  }
}
