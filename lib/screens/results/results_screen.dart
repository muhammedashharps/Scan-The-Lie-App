import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product.dart';
import '../../services/pdf_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/settings_repository.dart';

class ResultsScreen extends StatelessWidget {
  final Product product;
  final VoidCallback onChatPressed;
  final VoidCallback onBackPressed;
  final SettingsRepository settingsRepo;

  const ResultsScreen({
    super.key,
    required this.product,
    required this.onChatPressed,
    required this.onBackPressed,
    required this.settingsRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            color: AppColors.offWhite), // Or stick to clean white/gray
        child: SafeArea(
          child: DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBackPressed,
                    ),
                    title: Text(
                      'Scan Results',
                      style:
                          GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                    ),
                    centerTitle: true,
                    pinned: true,
                    floating: true,
                    elevation: 0,
                    backgroundColor: AppColors.white,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () {
                          PdfService().generateAndDownload(product);
                          settingsRepo.incrementSavedReportCount(product.id);
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: _buildHeaderView(context),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        labelColor: AppColors.black,
                        unselectedLabelColor: AppColors.gray,
                        indicatorColor: AppColors.cyan,
                        indicatorWeight: 3,
                        labelStyle: TextStyle(fontWeight: FontWeight.w700),
                        tabs: [
                          Tab(text: "Ingredients"),
                          Tab(text: "Personal"),
                          Tab(text: "Claims"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildIngredientsTab(),
                  _buildPersonalAnalysisTab(),
                  _buildClaimsTab(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onChatPressed,
        label: const Text('Ask AI Assistant',
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.chat_bubble_outline),
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildHeaderView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imagePath != null
                      ? Image.file(
                          File(product.imagePath!),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          color: AppColors.lightGray,
                          child: const Icon(Icons.image, color: AppColors.gray),
                        ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppColors.gray,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: product.claims
                            .take(2)
                            .map((c) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.offWhite,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(c,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary)),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Health Score
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Health Score',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: AppColors.gray,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${product.healthScore}/100',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.getScoreColor(product.healthScore)),
                    ),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.getScoreColor(product.healthScore)
                        .withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      product.scoreEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: product.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = product.ingredients[index];
        final riskColor = AppColors.getRiskColor(ingredient.riskLevel);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: riskColor.withOpacity(0.3)),
          ),
          child: ExpansionTile(
            title: Text(ingredient.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ingredient.riskLevel.toUpperCase(),
                style: TextStyle(
                    color: riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              _buildDetailRow('Purpose', ingredient.purpose),
              _buildDetailRow('Origin', ingredient.origin),
              if (ingredient.controversy.isNotEmpty &&
                  ingredient.controversy != 'None')
                _buildDetailRow('Controversy', ingredient.controversy,
                    isWarning: true),
              if (ingredient.bannedCountries.isNotEmpty)
                _buildDetailRow(
                    'Banned In', ingredient.bannedCountries.join(', '),
                    isWarning: true),
              _buildDetailRow('Safe Limit', ingredient.safeLimit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    if (value.isEmpty || value == 'Unknown') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isWarning ? AppColors.danger : AppColors.gray))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      color: isWarning ? AppColors.danger : AppColors.black,
                      height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildPersonalAnalysisTab() {
    final analysis = product.personalAnalysis;
    if (analysis == null) {
      return const Center(child: Text("No personalized analysis available."));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Compatibility Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: analysis.compatibility.toLowerCase() == 'high'
                ? AppColors.green.withOpacity(0.1)
                : (analysis.compatibility.toLowerCase() == 'medium'
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.danger.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                analysis.compatibility.toLowerCase() == 'high'
                    ? Icons.check_circle
                    : Icons.warning,
                color: analysis.compatibility.toLowerCase() == 'high'
                    ? AppColors.green
                    : (analysis.compatibility.toLowerCase() == 'medium'
                        ? AppColors.warning
                        : AppColors.danger),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compatibility',
                      style: TextStyle(fontSize: 12, color: AppColors.gray)),
                  Text(analysis.compatibility,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text("Health Considerations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (analysis.healthConsiderations.isEmpty)
          const Text("No specific health concerns found for you.",
              style: TextStyle(color: AppColors.gray)),

        ...analysis.healthConsiderations.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.severity == 'critical'
                    ? AppColors.danger.withOpacity(0.05)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: c.severity == 'critical'
                      ? AppColors.danger
                      : (c.severity == 'warning'
                          ? AppColors.warning
                          : AppColors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        c.severity == 'critical' ? Icons.dangerous : Icons.info,
                        size: 16,
                        color: c.severity == 'critical'
                            ? AppColors.danger
                            : AppColors.gray,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(c.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: c.severity == 'critical'
                                    ? AppColors.danger
                                    : AppColors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(c.description,
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            )),

        const SizedBox(height: 24),
        const Text("Recommendations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...analysis.recommendations.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(r, style: const TextStyle(height: 1.4))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildClaimsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: product.claimVerifications.length,
      itemBuilder: (context, index) {
        final claim = product.claimVerifications[index];
        final verdictColor = claim.verdict.toLowerCase() == 'verified' ||
                claim.verdict.toLowerCase() == 'true'
            ? AppColors.green
            : (claim.verdict.toLowerCase() == 'misleading'
                ? AppColors.warning
                : AppColors.danger);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '"${claim.claim}"',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: verdictColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      claim.verdict.toUpperCase(),
                      style: TextStyle(
                          color: verdictColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                claim.explanation,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent =>
      _tabBar.preferredSize.height +
      20; // +20 for bottom padding simulation if needed
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white, // Opaque background for sticky header
      padding: const EdgeInsets.only(bottom: 20), // Add padding to bottom
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
