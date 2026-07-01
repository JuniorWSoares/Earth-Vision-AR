# 🌍 EarthVision AR

> Inteligência Planetária na palma da mão — visualize a Terra em 3D e explore dados científicos em tempo real com uma interface estilo AR.

---

## 📱 Sobre o Projeto

**EarthVision AR** é um aplicativo Flutter com tema de realidade aumentada que permite explorar o planeta Terra de forma interativa e imersiva. Com uma estética inspirada em sistemas de monitoramento espacial, o app exibe dados geológicos, atmosféricos e orbitais em um painel estilo HUD (Heads-Up Display).

O projeto foi desenvolvido com foco em UI/UX futurista, animações fluidas e código Flutter limpo usando arquitetura baseada em features.

---

## ✨ Funcionalidades

- **🌐 Globo 3D Interativo** — Terra desenhada com `CustomPainter`, com rotação automática, drag para girar manualmente e pinch-to-zoom
- **📡 HUD em Tempo Real** — Painel sobreposto com dados simulados de satélite (temperatura, CO₂, cobertura de nuvens, sensores ativos) que atualizam a cada 3 segundos
- **🛰️ Tela de Visualização AR** — Fundo espacial com campo estelar determinístico, linha de scan animada, retículo central e informações orbitais
- **📊 Dados da Terra** — Tela detalhada com dados científicos: gravidade, diâmetro, velocidade de rotação, posição no sistema solar e composição atmosférica
- **🎨 Tema Dark Futurista** — Paleta cyan/dark space com tipografia Inter via Google Fonts

---

## 🗂️ Estrutura do Projeto

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart       # Paleta de cores centralizada
│       └── app_theme.dart        # Tema global dark
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/            # HomePage com nav bar
│   │       └── widgets/          # ActionCard, NavItem, LiveStatusBadge...
│   ├── earth_details/
│   │   └── presentation/
│   │       ├── pages/            # EarthDetailsPage
│   │       └── widgets/          # FactCard, AtmosphereChart, HeroPlanetSection
│   └── ar_view/
│       └── presentation/
│           ├── pages/            # ArViewPage (tela AR imersiva)
│           └── widgets/          # Earth3DViewer, ArHudOverlay, Earth3DPainter
└── main.dart
```

---

## 🚀 Como Rodar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- Dart `>=3.0.0 <4.0.0`

### Passos

```bash
# Clone o repositório
git clone https://github.com/JuniorWSoares/Earth-Vision-AR.git
cd earth-vision-ar

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

O app roda em **iOS**, **Android**, **Web**.

---

## 📦 Dependências

| Pacote | Versão | Uso |
|--------|--------|-----|
| [`google_fonts`](https://pub.dev/packages/google_fonts) | ^6.2.1 | Tipografia Inter |

---

## 🖼️ Telas

| Home | Dados da Terra | Visualização AR |
|------|---------------|-----------------|
| Painel principal com status ao vivo e cards de ação | Dados científicos e composição atmosférica | Globo 3D interativo com HUD de satélite |

---

## 🛠️ Tecnologias

- **Flutter** — Framework UI multiplataforma
- **CustomPainter** — Renderização do globo 3D e efeitos visuais
- **AnimationController** — Rotação automática, fade-in, scan line e pulso
- **GestureDetector + ScaleGesture** — Drag e pinch-to-zoom no globo
- **Timer.periodic** — Atualização dos dados simulados em tempo real

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

<div align="center">
  <sub>Dados científicos baseados em informações da NASA / JPL</sub>
</div>
