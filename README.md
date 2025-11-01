# MPAZ Voxel Tools Debug

Debug overlay for Voxel Tools development in Godot 4. Provides real-time performance metrics, player position, GPU information, and voxel statistics with color-coded performance indicators.

## Screenshots
#### F2 to show/hide
<img width="2047" height="1152" alt="image" src="https://github.com/user-attachments/assets/ae0f199c-ccf6-4d63-a234-58050ee2759f" />
#### Configurable
<img width="574" height="633" alt="image" src="https://github.com/user-attachments/assets/11682685-edec-4860-ac8f-0f30a264e143" />
---

## Features

### Core Metrics
- **FPS Display**: Real-time frames per second with color-coded performance indicators
- **Player Position (XYZ)**: Shows 3D coordinates for precise navigation and debugging
- **Memory Usage**: Displays RAM consumption in MB with performance thresholds
- **Frame Time**: Shows frame processing time in milliseconds
- **GPU Information**: Displays graphics card vendor and model
- **Voxel Statistics**: Shows mesh blocks, threads, and streaming information
- **Player Speed**: Optional velocity magnitude display
- **Render Stats**: Optional draw calls, objects, and vertex count

### Visual Features
- **Color-Coded Performance**: Automatic color indicators (green/yellow/red) based on thresholds
- **Multiple Display Modes**: Minimal, Compact, and Detailed layouts
- **Background Panel**: Optional semi-transparent background for better readability
- **Professional Formatting**: Clean text with shadows for visibility
- **Toggle Visibility**: Press F2 to show/hide debug overlay

### Performance & Quality
- **Optimized Updates**: Configurable update interval (default 0.5s)
- **Cached Data**: GPU info cached at startup for zero runtime overhead
- **RichTextLabel**: BBCode support for colored text
- **Non-Intrusive**: Mouse clicks pass through the overlay
- **Modular**: Enable/disable individual metrics

## How to Use

### Installation

1. Enable the plugin in `Project Settings > Plugins`
2. Add the `DebugInfo` scene to your main scene:
   - Drag `res://addons/mpaz_voxel_tools_debug/scenes/debug_info.tscn` into your scene
3. **Configure F2 toggle** (see "Setting Up F2 Toggle" below)

### Setting Up F2 Toggle

The debug overlay can be toggled on/off by pressing F2. You need to map this input action:

#### Method 1: Automatic (Recommended)

The `toggle_debug` input action should be added automatically. If it doesn't work:

1. **Close Godot completely**
2. **Reopen your project**
3. The F2 key will now work

#### Method 2: Manual Configuration

If automatic setup doesn't work, configure it manually:

1. Open **Project → Project Settings**
2. Go to the **Input Map** tab
3. In the "Add New Action" field, type: `toggle_debug`
4. Click **Add**
5. Click the **+** button next to `toggle_debug`
6. Select **Key** from the options
7. Press **F2** on your keyboard
8. Click **OK**
9. Close Project Settings

**Test it:** Run your game and press F2. You should see in the console:
```
🔧 Debug overlay toggled: visible
```
or
```
🔧 Debug overlay toggled: hidden
```

#### Using a Different Key

If you prefer a different key (F3, F4, H, etc.):
- Follow the manual configuration steps above
- Press your preferred key instead of F2 in step 7

### Configuration

Configure in the Inspector:

#### Node References
- **Player Path**: Drag your CharacterBody3D (player) node here
- **Terrain Path**: Drag your VoxelLodTerrain node here

#### Display Mode
- **Minimal**: FPS + Y coordinate only (best for recording/streaming)
- **Compact**: Essential info in condensed format (recommended)
- **Detailed**: Everything with category headers (full debug)

#### Display Options
Enable/disable individual metrics:
- **Show FPS**: Frames per second with color coding
- **Show Position XYZ**: Player 3D coordinates
- **Show Memory**: RAM usage in MB
- **Show Frame Time**: Frame processing time in ms
- **Show GPU Info**: Graphics card information
- **Show Voxel Stats**: VoxelEngine statistics
- **Show Render Stats**: Draw calls, objects, vertices
- **Show Player Speed**: Movement velocity

#### Visual Settings
- **Show Background**: Semi-transparent panel behind text
- **Background Opacity**: Adjust transparency (0.0-1.0)
- **Use Color Coding**: Enable/disable performance-based colors

#### Performance
- **Update Interval**: Refresh rate in seconds (0.5s recommended)

### Controls

- **F2**: Toggle debug overlay visibility on/off

## Display Formats

### Minimal Mode
```
FPS: 60
Y: 128.5
```

### Compact Mode (Default)
```
FPS: 60 | Frame: 16.7ms | RAM: 455MB
XYZ: 0.0, 128.5, 45.2
GPU: NVIDIA GeForce RTX 3080
Mesh Blocks: 1,024
Threads: 4
```

### Detailed Mode
```
=== PERFORMANCE ===
FPS:       60
Frame:     16.7 ms
RAM:       455 MB
Draws:     1,245
Objects:   3,782

=== POSITION ===
X:         0.0
Y:         128.5
Z:         45.2
Speed:     5.2 m/s

=== SYSTEM ===
GPU: NVIDIA GeForce RTX 3080
Mesh Blocks: 1,024
Threads:   4
```

## Color Coding Thresholds

### FPS (Frames Per Second)
- 🟢 **Green**: ≥ 55 FPS (excellent performance)
- 🟡 **Yellow**: 30-54 FPS (acceptable performance)
- 🔴 **Red**: < 30 FPS (performance issues)

### Memory (RAM Usage)
- 🟢 **Green**: < 500 MB (low usage)
- 🟡 **Yellow**: 500-1000 MB (moderate usage)
- 🔴 **Red**: > 1000 MB (high usage)

### Frame Time
- 🟢 **Green**: < 20 ms (smooth)
- 🟡 **Yellow**: 20-33 ms (acceptable)
- 🔴 **Red**: > 33 ms (lag detected)

*Target: <16.7ms for 60 FPS, <33.3ms for 30 FPS*

## Performance Considerations

Working with voxels requires careful attention to performance:

### Optimization Tips
- **Update Interval**: Default 0.5s balances freshness with minimal CPU overhead
- **Selective Display**: Disable metrics you don't need to reduce processing
- **Memory Monitoring**: Voxel games can be memory-intensive - watch RAM usage
- **Frame Time**: Monitor for consistent performance across different areas
- **Mesh Blocks**: High counts may indicate excessive chunk generation
- **Threads**: Check if voxel streaming is utilizing available CPU cores

### Voxel-Specific Metrics
- **Mesh Blocks**: Number of active voxel meshes in memory
- **Threads**: Worker threads used for meshing and streaming
- **View Distance**: Terrain rendering distance (from VoxelLodTerrain)

## Technical Details

### APIs Used
- `Engine.get_frames_per_second()` - FPS measurement
- `Performance.get_monitor()` - System metrics
- `RenderingServer.get_video_adapter_name()` - GPU information
- `VoxelEngine.get_stats()` - Voxel-specific data (when available)

### Features
- **RichTextLabel**: BBCode support for colored text
- **Input Action**: "toggle_debug" mapped to F2 key
- **Mouse Filter**: Clicks pass through overlay
- **Update Timer**: Non-blocking timer system
- **String Formatting**: Thousands separators for large numbers

## Compatibility

- **Godot**: 4.x
- **Voxel Tools**: zylann.voxel addon
- **Terrain Types**: VoxelLodTerrain and VoxelTerrain
- **Platforms**: All platforms supported by Godot

## Troubleshooting

### F2 Not Working
**Solution 1:** Close and reopen Godot to reload the project settings.

**Solution 2:** Manually add the input action:
1. Go to **Project → Project Settings → Input Map**
2. Add action `toggle_debug`
3. Map it to F2 key
4. See "Setting Up F2 Toggle" section above for detailed steps

**Verify:** When you press F2, check the console output for toggle messages.

### "Voxel: No Stats Available"
VoxelEngine.get_stats() may not be available in your version. The plugin will fallback to basic terrain detection.

### Colors Not Showing
Make sure "Use Color Coding" is enabled in Visual Settings.

### Background Not Visible
Enable "Show Background" and adjust "Background Opacity" (try 0.5-0.7).

### "Nonexistent function 'has' in base CharacterBody3D"
This error is fixed in the latest version. Make sure you're using the updated plugin files.

### Debug Info Not Appearing
1. Check that the DebugInfo node is visible in the scene tree (eye icon)
2. Verify that Player Path and Terrain Path are correctly set
3. Make sure the plugin is enabled in Project Settings > Plugins

## Credits

Author: Mauricio Paz
Instagram: @mauricio.paz.p
Linkedin: https://www.linkedin.com/in/m-paz/

