import 'package:flutter/material.dart';
import 'package:terra_explorer/features/ar_view/presentation/pages/ar_native_page.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/atmosphere_chart.dart';
import '../widgets/fact_card.dart';
import '../widgets/hero_planet_section.dart';

class EarthDetailsPage extends StatefulWidget {
  const EarthDetailsPage({super.key});

  @override
  State<EarthDetailsPage> createState() => _EarthDetailsPageState();
}

class _EarthDetailsPageState extends State<EarthDetailsPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'EarthVision AR',
          style: TextStyle(
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.white10, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroPlanetSection(),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
              childAspectRatio:
                  MediaQuery.of(context).size.width > 600 ? 3.2 : 2.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: const [
                FactCard(
                  label: 'Gravidade Superficial',
                  value: '9,8 m/s²',
                  description: 'Aceleração padrão',
                  icon: Icons.vertical_align_bottom,
                ),
                FactCard(
                  label: 'Diâmetro Médio',
                  value: '12.742 km',
                  description: 'Distância entre os polos',
                  icon: Icons.straighten,
                ),
                FactCard(
                  label: 'Posição no Sistema',
                  value: '3º Planeta',
                  description: 'Na zona habitável',
                  icon: Icons.star,
                ),
                FactCard(
                  label: 'Velocidade de Rotação',
                  value: '1.670 km/h',
                  description: 'Velocidade no equador',
                  icon: Icons.autorenew,
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Composição Atmosférica',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const AtmosphereChart(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.white30,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
            return;
          }
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ArNativePage()),
            );
            return;
          }
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.public), label: 'EXPLORAR'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'DADOS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar), label: 'VER EM AR'),
        ],
      ),
    );
  }
}
