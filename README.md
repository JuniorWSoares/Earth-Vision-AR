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

---

### 🤖 Android

**Requisitos:** Android Studio instalado, emulador configurado ou dispositivo físico com USB debugging ativo.

```bash
# Verifique se o dispositivo está conectado
flutter devices

# Rode no Android
flutter run -d android

# Gerar APK de release
flutter build apk --release
# O arquivo ficará em: build/app/outputs/flutter-apk/app-release.apk

# Gerar App Bundle para Google Play
flutter build appbundle --release
```

> **Versão mínima:** Android 5.0 (API 21). A permissão de internet já está configurada no `AndroidManifest.xml` para carregar imagens e dados de rede.

---

### 🍎 iOS

**Requisitos:** macOS com Xcode 14 ou superior. Para rodar em dispositivo físico é necessário uma conta Apple Developer.

```bash
# Instale as dependências nativas
cd ios && pod install && cd ..

# Rode no simulador iOS
flutter run -d ios

# Rode em dispositivo físico (deve estar listado em flutter devices)
flutter run -d <device-id>

# Gerar build de release (abre o Xcode para assinar e exportar)
flutter build ios --release
```

> A chave `NSCameraUsageDescription` já está declarada no `Info.plist` — exigida pela App Store para qualquer app que acesse a câmera.

---

### 🌐 Web

**Requisitos:** Navegador moderno. Para a funcionalidade de AR (`ar.html`) é necessário HTTPS e Chrome 81+ no Android ou Safari 12+ no iOS.

```bash
# Rode localmente com hot reload
flutter run -d chrome

# Build de produção
flutter build web --release
# Os arquivos ficam em: build/web/
```

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
