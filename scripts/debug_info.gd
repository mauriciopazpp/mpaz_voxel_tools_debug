extends Control
class_name MPAZVoxelToolsDebug

## Professional debug overlay for Voxel Tools development
## Displays FPS, player position, memory usage, GPU info, and voxel statistics
## Toggle visibility with F2

## Reference to the player node (CharacterBody3D)
## Drag and drop your player node here to display position information
@export_node_path("CharacterBody3D") var player_path: NodePath

## Reference to the VoxelLodTerrain node
## Drag and drop your VoxelLodTerrain node here to display voxel statistics
@export_node_path("VoxelLodTerrain") var terrain_path: NodePath

@export_group("Display Mode")

## Display mode: Minimal (FPS+Y only), Compact (essential info), Detailed (everything with categories)
## Minimal: Best for recording/streaming. Compact: Balanced. Detailed: Full debug information
@export_enum("Minimal", "Compact", "Detailed") var display_mode: int = 1  # Default: Compact

@export_group("Display Options")

## Display frames per second (FPS) with color-coded performance indicators
## Green: ≥55 FPS | Yellow: 30-54 FPS | Red: <30 FPS
@export var show_fps: bool = true

## Display player position coordinates (X, Y, Z)
## Shows the player's 3D position in world space
@export var show_position_xyz: bool = true

## Display memory usage in MB with color-coded indicators
## Green: <500 MB | Yellow: 500-1000 MB | Red: >1000 MB
@export var show_memory: bool = true

## Display frame time in milliseconds with color-coded indicators
## Green: <20ms | Yellow: 20-33ms | Red: >33ms (target: <16.7ms for 60 FPS)
@export var show_frame_time: bool = true

## Display GPU information (vendor and model name)
## Shows which graphics card is being used for rendering
@export var show_gpu_info: bool = true

## Display voxel engine statistics (mesh blocks, threads, etc.)
## Shows information about the voxel streaming and meshing system
@export var show_voxel_stats: bool = true

## Display additional rendering statistics (draw calls, vertices, objects)
## Useful for identifying rendering bottlenecks
@export var show_render_stats: bool = false

## Display player speed (velocity magnitude)
## Shows how fast the player is moving in units per second
@export var show_player_speed: bool = false

@export_group("Visual Settings")

## Show semi-transparent background panel behind the text
## Improves readability on bright or busy backgrounds (disabled by default)
@export var show_background: bool = false

## Background panel opacity (0.0 = fully transparent, 1.0 = fully opaque)
## Recommended: 0.3-0.7 for good contrast without blocking too much
@export_range(0.0, 1.0) var background_opacity: float = 0.5

## Use color coding for performance metrics
## Disabling shows all text in default color (better for color-blind accessibility)
@export var use_color_coding: bool = true

@export_group("Performance")

## Update interval in seconds
## How often to refresh the debug information (lower = more updates but slightly more CPU usage)
@export var update_interval: float = 0.5

# Internal variables
var _timer: float = 0.0
var _label: RichTextLabel
var _player: CharacterBody3D
var _terrain: VoxelLodTerrain
var _visible_debug: bool = true
var _gpu_name: String = ""  # Cached GPU name
var _background_panel: ColorRect

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create background panel if enabled
	if show_background:
		_create_background_panel()
	
	# Create or find label
	if not _check_if_label_exists():
		_label = RichTextLabel.new()
		_label.position = Vector2(10, 10)
		_label.size = Vector2(500, 600)  # Set initial size
		_label.bbcode_enabled = true
		_label.fit_content = true
		_label.scroll_active = false
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.add_theme_font_size_override("normal_font_size", 18)
		_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		_label.add_theme_constant_override("shadow_offset_x", 2)
		_label.add_theme_constant_override("shadow_offset_y", 2)
		add_child(_label)
	
	if _label:
		_label.text = "[color=yellow]Debug Info Loading...[/color]"
	
	# Cache GPU info (doesn't change during runtime)
	_gpu_name = _get_gpu_info()
	
	_get_references()

func _check_if_label_exists() -> bool:
	for child in get_children():
		if child is RichTextLabel:
			_label = child
			_label.bbcode_enabled = true
			_label.size = Vector2(500, 600)
			_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			return true
	return false

func _create_background_panel():
	_background_panel = ColorRect.new()
	_background_panel.position = Vector2(5, 5)
	_background_panel.color = Color(0, 0, 0, background_opacity)
	_background_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background_panel)
	move_child(_background_panel, 0)  # Behind everything else

func _get_references():
	if player_path:
		_player = get_node_or_null(player_path)
		if not _player:
			push_warning("MPAZVoxelToolsDebug: Player node not found at path: ", player_path)
	
	if terrain_path:
		_terrain = get_node_or_null(terrain_path)
		if not _terrain:
			push_warning("MPAZVoxelToolsDebug: Terrain node not found at path: ", terrain_path)

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		_visible_debug = !_visible_debug
		_label.visible = _visible_debug
		if _background_panel:
			_background_panel.visible = _visible_debug
		print("🔧 Debug overlay toggled: ", "visible" if _visible_debug else "hidden")
		get_viewport().set_input_as_handled()

func _process(delta: float):
	if not _visible_debug:
		return
	
	_timer += delta
	if _timer >= update_interval:
		_update_info()
		_timer = 0.0

func _update_info():
	var lines: Array[String] = []
	
	match display_mode:
		0:  # Minimal
			_build_minimal_display(lines)
		1:  # Compact
			_build_compact_display(lines)
		2:  # Detailed
			_build_detailed_display(lines)
	
	# Use BBCode for colored text
	_label.text = "\n".join(lines)
	
	# Update background size if enabled
	if _background_panel and show_background:
		var line_count = lines.size()
		var estimated_height = line_count * 25 + 20
		_background_panel.size = Vector2(500, estimated_height)

func _build_minimal_display(lines: Array[String]):
	# Minimal: FPS + Y coordinate only
	if show_fps:
		var fps = Engine.get_frames_per_second()
		var color = _get_color_for_fps(fps) if use_color_coding else Color.YELLOW
		lines.append(_colorize("FPS: %d" % fps, color))
	
	if show_position_xyz and _player:
		var y = _player.global_position.y
		var color = Color.YELLOW if not use_color_coding else Color.YELLOW
		lines.append(_colorize("Y: %.1f" % y, color))

func _build_compact_display(lines: Array[String]):
	# Compact: Essential info in condensed format
	var perf_line = ""
	
	# FPS
	if show_fps:
		var fps = Engine.get_frames_per_second()
		var color = _get_color_for_fps(fps) if use_color_coding else Color.YELLOW
		perf_line += _colorize("FPS: %d" % fps, color)
	
	# Frame Time
	if show_frame_time:
		var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		var color = _get_color_for_frame_time(frame_time) if use_color_coding else Color.YELLOW
		if perf_line != "":
			perf_line += " | "
		perf_line += _colorize("Frame: %.1fms" % frame_time, color)
	
	# Memory
	if show_memory:
		var memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
		var memory_mb = int(memory_bytes / 1048576.0)
		var color = _get_color_for_memory(memory_mb) if use_color_coding else Color.YELLOW
		if perf_line != "":
			perf_line += " | "
		perf_line += _colorize("RAM: %dMB" % memory_mb, color)
	
	if perf_line != "":
		lines.append(perf_line)
	
	# Position XYZ
	if show_position_xyz and _player:
		var pos = _player.global_position
		lines.append(_colorize("XYZ: %.1f, %.1f, %.1f" % [pos.x, pos.y, pos.z], Color.CYAN))
	
	# Player Speed
	if show_player_speed and _player:
		var speed = _player.velocity.length()
		lines.append(_colorize("Speed: %.1f m/s" % speed, Color.LIGHT_BLUE))
	
	# GPU
	if show_gpu_info and _gpu_name != "":
		lines.append(_colorize("GPU: %s" % _gpu_name, Color.ORANGE))
	
	# Voxel Stats (compact)
	if show_voxel_stats:
		_add_voxel_stats_compact(lines)

func _build_detailed_display(lines: Array[String]):
	# Detailed: Everything organized in categories
	
	# === PERFORMANCE ===
	lines.append(_colorize("PERFORMANCE", Color.WHITE))
	
	if show_fps:
		var fps = Engine.get_frames_per_second()
		var color = _get_color_for_fps(fps) if use_color_coding else Color.YELLOW
		lines.append(_colorize("FPS:       %d" % fps, color))
	
	if show_frame_time:
		var frame_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		var color = _get_color_for_frame_time(frame_time) if use_color_coding else Color.YELLOW
		lines.append(_colorize("Frame:     %.1f ms" % frame_time, color))
	
	if show_memory:
		var memory_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
		var memory_mb = int(memory_bytes / 1048576.0)
		var color = _get_color_for_memory(memory_mb) if use_color_coding else Color.YELLOW
		lines.append(_colorize("RAM:       %d MB" % memory_mb, color))
	
	if show_render_stats:
		var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		var objects = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		lines.append(_colorize("Draws:     %d" % draw_calls, Color.LIGHT_GRAY))
		lines.append(_colorize("Objects:   %d" % objects, Color.LIGHT_GRAY))
	
	# === POSITION ===
	if show_position_xyz and _player:
		lines.append("")
		lines.append(_colorize("POSITION", Color.WHITE))
		var pos = _player.global_position
		lines.append(_colorize("X:         %.1f" % pos.x, Color.CYAN))
		lines.append(_colorize("Y:         %.1f" % pos.y, Color.CYAN))
		lines.append(_colorize("Z:         %.1f" % pos.z, Color.CYAN))
		
		if show_player_speed:
			var speed = _player.velocity.length()
			lines.append(_colorize("Speed:     %.1f m/s" % speed, Color.LIGHT_BLUE))
	
	# === SYSTEM ===
	if show_gpu_info or show_voxel_stats:
		lines.append("")
		lines.append(_colorize("SYSTEM", Color.WHITE))
		
		if show_gpu_info and _gpu_name != "":
			lines.append(_colorize("GPU: %s" % _gpu_name, Color.ORANGE))
		
		if show_voxel_stats:
			_add_voxel_stats_detailed(lines)

func _add_voxel_stats_compact(lines: Array[String]):
	# Try to get VoxelEngine stats
	if Engine.has_singleton("VoxelEngine"):
		var voxel_engine = Engine.get_singleton("VoxelEngine")
		if voxel_engine and voxel_engine.has_method("get_stats"):
			var stats = voxel_engine.get_stats()
			# Debug: print the stats structure once to understand it
			if stats and typeof(stats) == TYPE_DICTIONARY:
				# Try different possible keys
				var blocks_count = 0
				var thread_count = 0
				
				# Check various possible structures
				if stats.has("streaming"):
					if stats["streaming"].has("mesh_blocks"):
						blocks_count = stats["streaming"]["mesh_blocks"]
				elif stats.has("mesh_blocks"):
					blocks_count = stats["mesh_blocks"]
				
				if stats.has("tasks"):
					if stats["tasks"].has("thread_count"):
						thread_count = stats["tasks"]["thread_count"]
				elif stats.has("thread_count"):
					thread_count = stats["thread_count"]
				
				if blocks_count > 0:
					lines.append(_colorize("Mesh Blocks: %s" % _format_number(blocks_count), Color.LIGHT_GREEN))
				if thread_count > 0:
					lines.append(_colorize("Threads: %d" % thread_count, Color.LIGHT_GREEN))
			else:
				lines.append(_colorize("Voxel: Active", Color.GRAY))
		else:
			lines.append(_colorize("Voxel: No Stats Available", Color.DARK_GRAY))
	else:
		if _terrain:
			lines.append(_colorize("Terrain: Active", Color.GRAY))

func _add_voxel_stats_detailed(lines: Array[String]):
	# Detailed voxel stats
	if Engine.has_singleton("VoxelEngine"):
		var voxel_engine = Engine.get_singleton("VoxelEngine")
		if voxel_engine and voxel_engine.has_method("get_stats"):
			var stats = voxel_engine.get_stats()
			if stats and typeof(stats) == TYPE_DICTIONARY:
				# Try to extract all available stats
				var blocks_count = 0
				var thread_count = 0
				
				if stats.has("streaming"):
					var streaming = stats["streaming"]
					if streaming.has("mesh_blocks"):
						blocks_count = streaming["mesh_blocks"]
					if streaming.has("loaded_blocks"):
						lines.append(_colorize("Loaded:    %s" % _format_number(streaming["loaded_blocks"]), Color.LIGHT_GREEN))
				elif stats.has("mesh_blocks"):
					blocks_count = stats["mesh_blocks"]
				
				if blocks_count > 0:
					lines.append(_colorize("Mesh Blocks: %s" % _format_number(blocks_count), Color.LIGHT_GREEN))
				
				if stats.has("tasks"):
					var tasks = stats["tasks"]
					if tasks.has("thread_count"):
						thread_count = tasks["thread_count"]
					if tasks.has("active_tasks"):
						lines.append(_colorize("Tasks:     %d" % tasks["active_tasks"], Color.LIGHT_GREEN))
				elif stats.has("thread_count"):
					thread_count = stats["thread_count"]
				
				if thread_count > 0:
					lines.append(_colorize("Threads:   %d" % thread_count, Color.LIGHT_GREEN))
			else:
				lines.append(_colorize("Voxel Engine: Active", Color.GRAY))
		else:
			lines.append(_colorize("Voxel Stats: Not Available", Color.DARK_GRAY))
	else:
		if _terrain:
			lines.append(_colorize("VoxelLodTerrain: Active", Color.GRAY))
			lines.append(_colorize("View Distance: %d" % _terrain.view_distance, Color.GRAY))

func _get_gpu_info() -> String:
	var adapter_name = RenderingServer.get_video_adapter_name()
	# Clean up the name (remove extra info sometimes included)
	var clean_name = adapter_name.split("/")[0].strip_edges()
	return clean_name

func _get_color_for_fps(fps: int) -> Color:
	if fps >= 55:
		return Color.GREEN
	elif fps >= 30:
		return Color.YELLOW
	else:
		return Color.RED

func _get_color_for_memory(mb: int) -> Color:
	if mb < 500:
		return Color.GREEN
	elif mb < 1000:
		return Color.YELLOW
	else:
		return Color.RED

func _get_color_for_frame_time(ms: float) -> Color:
	if ms < 20.0:
		return Color.GREEN
	elif ms < 33.0:
		return Color.YELLOW
	else:
		return Color.RED

func _colorize(text: String, color: Color) -> String:
	# Use BBCode color tags for RichTextLabel
	var hex = color.to_html(false)
	return "[color=#%s]%s[/color]" % [hex, text]

func _format_number(n: int) -> String:
	var s = str(n)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
