import 'package:flutter/material.dart';
import 'package:terra_explorer/features/ar_view/presentation/pages/ar_native_page.dart';
import 'package:terra_explorer/features/earth_details/presentation/pages/earth_details_page.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/action_card.dart';
import '../widgets/footer_info_item.dart';
import '../widgets/live_status_badge.dart';
import '../widgets/nav_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const EarthDetailsPage()))
            .then((_) => setState(() => _selectedIndex = 0));
        return;
      case 2:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ArNativePage()))
            .then((_) => setState(() => _selectedIndex = 0));
        return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'EarthVision AR',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const LiveStatusBadge(),
              const SizedBox(height: 32),
              const Text(
                'Inteligência\nPlanetária',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Acesse dados da Terra em tempo real e visualize o planeta em Realidade Aumentada.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white60,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              ActionCard(
                icon: Icons.public,
                title: 'DADOS DA TERRA',
                description:
                    'Explore dados geológicos e meteorológicos de sensores globais.',
                buttonText: 'ACESSAR ARQUIVO',
                onTap: () => _onNavTap(1),
              ),
              const SizedBox(height: 24),
              ActionCard(
                icon: Icons.view_in_ar,
                title: 'VER EM AR',
                description:
                    'Posicione o planeta Terra em cima de uma superfície real.',
                buttonText: 'INICIAR AR',
                onTap: () => _onNavTap(2),
              ),
              const SizedBox(height: 40),
              const FooterInfoItem(
                  icon: Icons.sensors, label: '14.293 SENSORES ONLINE'),
              const FooterInfoItem(
                  icon: Icons.history, label: 'ÚLTIMA SINC: HÁ 14 SEG'),
              const FooterInfoItem(
                  icon: Icons.security,
                  label: 'PROTOCOLO TERRA CRIPTOGRAFADO'),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
              icon: Icons.public,
              label: 'EXPLORAR',
              isActive: _selectedIndex == 0,
              onTap: () => _onNavTap(0),
            ),
            NavItem(
              icon: Icons.analytics_outlined,
              label: 'DADOS',
              isActive: _selectedIndex == 1,
              onTap: () => _onNavTap(1),
            ),
            NavItem(
              icon: Icons.view_in_ar_outlined,
              label: 'VER EM AR',
              isActive: _selectedIndex == 2,
              onTap: () => _onNavTap(2),
            ),
          ],
        ),
      ),
    );
  }
}
