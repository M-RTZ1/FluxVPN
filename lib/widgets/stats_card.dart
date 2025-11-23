import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluxvpn/theme/app_theme.dart';
import 'package:fluxvpn/utils/translations.dart';

class StatsCard extends StatelessWidget {
  final String downloadSpeed;
  final String uploadSpeed;
  final String totalDownload;
  final String totalUpload;
  final bool isConnected;

  const StatsCard({
    super.key,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.totalDownload,
    required this.totalUpload,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Download Stats
          Builder(
            builder: (context) => _buildStatItem(
              context: context,
              icon: FluentIcons.download,
              label: 'Download',
              speed: downloadSpeed,
              total: totalDownload,
              color: const Color(0xFF00D9A3),
            ),
          ),
          
          // Divider
          Container(
            width: 1,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Upload Stats
          Builder(
            builder: (context) => _buildStatItem(
              context: context,
              icon: FluentIcons.upload,
              label: 'Upload',
              speed: uploadSpeed,
              total: totalUpload,
              color: const Color(0xFF6B4CE6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String speed,
    required String total,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          
          // Label
          Text(
            Translations.tr(context, label),
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          
          // Speed
          Text(
            speed,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          
          // Total
          Text(
            total,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
