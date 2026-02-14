# FASHIN Play - Testing Guide

## Pre-build Checklist

### ✅ Phase 1: Configuration
- [x] pubspec.yaml simplified (removed desktop dependencies)
- [x] AndroidManifest.xml updated to "FASHIN Play"
- [x] main.dart simplified (no desktop code)

### ✅ Phase 2: Theme System
- [x] app_theme.dart with light/dark themes
- [x] Batik pattern CustomPainter
- [x] Theme provider with persistence

### ✅ Phase 3: Data Models
- [x] Song model
- [x] Playlist model

### ✅ Phase 4: Services
- [x] YouTube service (search & stream)
- [x] Audio service (just_audio wrapper)
- [x] Lyrics service (LRCLIB API)

### ✅ Phase 5: State Management
- [x] Audio provider
- [x] Playlist provider
- [x] Theme provider

### ✅ Phase 6: UI Components
- [x] Greeting header with "FAIZ 💕 SHINTA"
- [x] Batik painter (Kawung pattern)
- [x] Mini player
- [x] Song tile
- [x] Recommendation card

### ✅ Phase 7: Screens
- [x] Home screen (greeting + recommendations)
- [x] Search screen
- [x] Player screen (with synced lyrics)
- [x] Playlist screen
- [x] Playlist detail screen
- [x] Equalizer screen
- [x] Main shell (bottom nav + mini player)

## Build Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run on Device/Emulator
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

### 3. Build APK
```bash
flutter build apk --release
```

## Manual Testing Checklist

### Home Screen
- [ ] Greeting header displays correctly
- [ ] Time-based greeting changes (pagi/siang/sore/malam)
- [ ] "FAIZ 💕 SHINTA" displays with gradient
- [ ] Batik pattern visible in background
- [ ] 3 recommendation sections visible
- [ ] Cards scrollable horizontally
- [ ] Tap on card searches and plays song

### Search Screen
- [ ] Search bar works
- [ ] Typing shows results
- [ ] Clear button works
- [ ] Results display with album art
- [ ] Tap on result plays song
- [ ] Loading indicator shows during search

### Player Screen
- [ ] Opens when tapping mini player
- [ ] Album art displays
- [ ] Song title and artist visible
- [ ] Progress bar works
- [ ] Play/pause toggle works
- [ ] Next/previous buttons work
- [ ] Seek bar functional
- [ ] Lyrics section displays
- [ ] Synced lyrics highlight current line
- [ ] Batik pattern in background

### Mini Player
- [ ] Appears when song playing
- [ ] Shows album art, title, artist
- [ ] Progress bar animates
- [ ] Play/pause works
- [ ] Next button works
- [ ] Tap opens full player

### Playlist Screen
- [ ] Shows recommended playlists
- [ ] Shows user playlists
- [ ] Create playlist works
- [ ] Delete playlist works
- [ ] Tap opens playlist detail

### Playlist Detail
- [ ] Shows playlist info
- [ ] Lists all songs
- [ ] Play all button works
- [ ] Tap song plays it
- [ ] Empty state shows when no songs

### Equalizer
- [ ] Opens from settings
- [ ] Preset chips work
- [ ] Band sliders work (Android only)
- [ ] Shows unavailable message on non-Android

### Theme Toggle
- [ ] Settings menu opens
- [ ] Dark/light toggle works
- [ ] Colors change correctly
- [ ] Text readable in both modes
- [ ] Preference persists after restart

### Bottom Navigation
- [ ] 3 tabs: Beranda, Cari, Playlist
- [ ] Icons correct
- [ ] Tab switching works
- [ ] Selected state visible

## Known Limitations

1. **Equalizer**: Android only
2. **Lyrics**: May not be available for all songs
3. **YouTube**: Requires internet connection
4. **Performance**: First search may be slow

## Common Issues

### Issue: "Equalizer not available"
**Solution**: This is normal on non-Android devices.

### Issue: "Song not found"
**Solution**: Try different search terms or check internet connection.

### Issue: "Lyrics not available"
**Solution**: Not all songs have lyrics in LRCLIB database.

### Issue: Slow loading
**Solution**: First YouTube search caches data, subsequent searches faster.

## Security Notes

- No API keys exposed
- No user data collected
- All data stored locally
- No network tracking

## Performance Checks

- [ ] App launches quickly
- [ ] Smooth scrolling
- [ ] No lag on theme switch
- [ ] Audio plays without buffering
- [ ] UI responsive during playback

## Accessibility

- [ ] Touch targets >= 48dp
- [ ] Text contrast sufficient
- [ ] Icons clear and recognizable
- [ ] Error messages clear

---

**Ready for deployment!** ��
