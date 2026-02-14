# FASHIN Play 🎵

Aplikasi musik mobile sederhana dan elegan dengan tema batik Indonesia.

## Fitur Utama

### 1. ✅ Streaming Musik dari YouTube
- Cari dan putar musik langsung dari YouTube tanpa API key
- Menggunakan `youtube_explode_dart` untuk streaming
- Audio player dengan `just_audio`

### 2. 🎤 Lirik Sinkron
- Fetch lirik dari LRCLIB API
- Lirik berjalan otomatis sesuai pemutaran
- Highlight baris aktif untuk synced lyrics
- Fallback ke lirik statis

### 3. 🎨 Tema Batik Indonesia
- **Light Mode**: Background putih, primary color biru muda (#81D4FA)
- **Dark Mode**: Background gelap (#121212), primary color biru terang
- Pattern batik Kawung sebagai dekorasi
- Warna aksen biru tua untuk kontras
- Font dapat dibaca dengan jelas di kedua mode

### 4. 📱 Mobile-Friendly
- Bottom navigation bar
- Mini player di bawah
- Full screen player
- Touch targets 48dp minimum
- Safe area handling

### 5. 🎼 Rekomendasi Lagu
**Beranda** dengan 3 section:
- **Trending Minggu Ini**: Campuran lagu Indonesia & Barat
- **Lagu Indonesia Populer**: Mahalini, Tulus, Nadin Amizah, dll
- **Lagu Barat Populer**: Taylor Swift, The Weeknd, Dua Lipa, dll

### 6. 📝 Playlist
- **My Playlist**: Buat dan kelola playlist sendiri
- **Rekomendasi Playlist**:
  - Indo Hits 2024
  - Galau Time
  - Semangat Pagi
  - Western Pop Hits
  - Lo-Fi Chill

### 7. 🎚️ Equalizer
- Native Android equalizer
- Preset: Normal, Rock, Pop, Jazz, Bass Boost, dll
- Custom band sliders

### 8. 🌓 Dark/Light Mode
- Toggle switch di settings
- Warna font readable di semua mode
- Simpan preferensi lokal

### 9. 🚀 Tanpa Login
- Tidak perlu autentikasi
- Semua data tersimpan lokal
- Privacy-focused

### 10. 💕 Sapaan Personal
Header di beranda dengan:
- Sapaan sesuai waktu (pagi/siang/sore/malam)
- "FAIZ 💕 SHINTA"
- "Selamat mendengarkan"
- Animasi fade-in
- Gradient biru dengan batik pattern

## Struktur Project

```
lib/
├── main.dart                      # Entry point
├── core/theme/
│   └── app_theme.dart            # Light & dark theme
├── models/
│   ├── song_model.dart           # Model lagu
│   └── playlist_model.dart       # Model playlist
├── services/
│   ├── audio_service.dart        # Audio player service
│   ├── youtube_service.dart      # YouTube search & stream
│   └── lyrics_service.dart       # Lyrics fetcher
├── providers/
│   ├── audio_provider.dart       # Audio state management
│   ├── playlist_provider.dart    # Playlist management
│   └── theme_provider.dart       # Theme state
├── ui/
│   ├── screens/
│   │   ├── home_screen.dart      # Beranda + greeting
│   │   ├── search_screen.dart    # Cari lagu
│   │   ├── player_screen.dart    # Full player + lirik
│   │   ├── playlist_screen.dart  # Daftar playlist
│   │   ├── playlist_detail_screen.dart
│   │   ├── equalizer_screen.dart # Equalizer UI
│   │   └── main_shell.dart       # Bottom nav + mini player
│   └── widgets/
│       ├── greeting_header.dart  # Header dengan sapaan
│       ├── batik_painter.dart    # Custom painter batik
│       ├── mini_player.dart      # Mini player bar
│       ├── song_tile.dart        # Song list item
│       └── recommendation_card.dart
```

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9     # State management
  just_audio: ^0.9.36          # Audio player
  audio_service: ^0.18.12      # Background audio
  youtube_explode_dart: ^2.5.0 # YouTube streaming
  equalizer_flutter: ^0.0.1    # Android EQ
  google_fonts: ^6.1.0         # Fonts
  shared_preferences: ^2.2.2   # Local storage
  http: ^1.0.0                 # HTTP requests
  intl: 0.20.2                 # Date formatting
```

## Build & Run

### Prerequisites
- Flutter SDK >= 3.2.3
- Android SDK (untuk Android)
- Dart SDK

### Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## Fitur Tambahan

- **Kontrol Pemutaran**: Play, pause, next, previous, seek
- **Queue Management**: Kelola antrian lagu
- **Persistent Storage**: Playlist & settings tersimpan
- **Error Handling**: Graceful error messages
- **Loading States**: Indikator loading yang jelas

## Catatan

- **TANPA API Spotify** - hanya YouTube
- **Mobile Only** - fokus Android
- **Lightweight** - dependencies minimal
- **Privacy** - tidak ada tracking

## Theme Colors

### Light Mode
- Primary: `#81D4FA` (Light Blue)
- Accent: `#0277BD` (Dark Blue)
- Background: `#FFFFFF` (White)
- Text: `#212121` (Dark Gray)

### Dark Mode
- Primary: `#4FC3F7` (Lighter Blue)
- Accent: `#81D4FA` (Light Blue)
- Background: `#121212` (Dark)
- Text: `#FFFFFF` (White)

---

**FASHIN Play** - Simple Music Player dengan sentuhan Indonesia 🇮🇩
