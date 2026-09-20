@tool
class_name BlurCompositorEffect extends CompositorEffect

const BLUR_SHADER: RDShaderFile = preload("res://prefabs/player/blur_effect.glsl")
const SCRATCH_NAME: StringName = &"scratch"
const WORKGROUP_SIZE: int = 8
const PUSH_CONSTANT_SIZE: int = 32

@export_range(0.0, 20.0, 0.1, "or_greater") var blur_size: float = 0.0

var _rd: RenderingDevice
var _shader: RID
var _pipeline: RID
var _sampler: RID
var _initialization_attempted: bool = false
var _context: StringName


func _init() -> void:
	enabled = false
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	access_resolved_color = true
	_context = StringName("blur_compositor_%s" % get_instance_id())


func _notification(what: int) -> void:
	if what != NOTIFICATION_PREDELETE: return
	# Capture values only: the effect must not be referenced after PREDELETE.
	var shader: RID = _shader
	var sampler: RID = _sampler
	if not shader.is_valid() and not sampler.is_valid(): return
	RenderingServer.call_on_render_thread(func() -> void:
		var rd: RenderingDevice = RenderingServer.get_rendering_device()
		if rd == null: return
		# Freeing a shader also invalidates its pipelines and cached uniform sets.
		if shader.is_valid(): rd.free_rid(shader)
		if sampler.is_valid(): rd.free_rid(sampler)
	)


func _initialize() -> bool:
	if _initialization_attempted: return _pipeline.is_valid() and _sampler.is_valid()
	_initialization_attempted = true
	_rd = RenderingServer.get_rendering_device()
	if _rd == null: return false
	var spirv: RDShaderSPIRV = BLUR_SHADER.get_spirv()
	var error: String = spirv.get_stage_compile_error(RenderingDevice.SHADER_STAGE_COMPUTE)
	if not error.is_empty():
		push_error("Blur compositor shader compilation failed: %s" % error)
		return false
	_shader = _rd.shader_create_from_spirv(spirv)
	if not _shader.is_valid(): return false
	_pipeline = _rd.compute_pipeline_create(_shader)
	if not _pipeline.is_valid(): return false
	var sampler_state: RDSamplerState = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.repeat_u = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_v = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	sampler_state.repeat_w = RenderingDevice.SAMPLER_REPEAT_MODE_CLAMP_TO_EDGE
	_sampler = _rd.sampler_create(sampler_state)
	return _sampler.is_valid()


func _render_callback(callback_type: int, render_data: RenderData) -> void:
	var spacing: float = blur_size
	if callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT or spacing <= 0.0: return
	var buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers() as RenderSceneBuffersRD
	if buffers == null: return
	var size: Vector2i = buffers.get_internal_size()
	if size.x <= 0 or size.y <= 0: return
	if not _initialize(): return
	var views: int = buffers.get_view_count()
	if buffers.has_texture(_context, SCRATCH_NAME):
		var format: RDTextureFormat = _rd.texture_get_format(buffers.get_texture(_context, SCRATCH_NAME))
		if format.width != size.x or format.height != size.y or format.array_layers != views:
			buffers.clear_context(_context)
	if not buffers.has_texture(_context, SCRATCH_NAME):
		buffers.create_texture(_context, SCRATCH_NAME,
			RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT,
			RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT,
			RenderingDevice.TEXTURE_SAMPLES_1, size, views, 1, false, false)

	# Convert output-pixel spacing to internal pixels without downsampling the passes.
	var target_size: Vector2i = buffers.get_target_size()
	var scale: Vector2 = Vector2.ONE
	if target_size.x > 0 and target_size.y > 0:
		scale = Vector2(size) / Vector2(target_size)
	var horizontal: PackedByteArray = _push_constants(size, Vector2(scale.x, 0.0), spacing)
	var vertical: PackedByteArray = _push_constants(size, Vector2(0.0, scale.y), spacing)
	var groups_x: int = ceili(float(size.x) / WORKGROUP_SIZE)
	var groups_y: int = ceili(float(size.y) / WORKGROUP_SIZE)
	for view: int in range(views):
		var color: RID = buffers.get_color_layer(view)
		var scratch: RID = buffers.get_texture_slice(_context, SCRATCH_NAME, view, 0, 1, 1)
		var horizontal_set: RID = _uniform_set(color, scratch)
		var vertical_set: RID = _uniform_set(scratch, color)
		var compute_list: int = _rd.compute_list_begin()
		_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline)
		_rd.compute_list_bind_uniform_set(compute_list, horizontal_set, 0)
		_rd.compute_list_set_push_constant(compute_list, horizontal, PUSH_CONSTANT_SIZE)
		_rd.compute_list_dispatch(compute_list, groups_x, groups_y, 1)
		_rd.compute_list_add_barrier(compute_list)
		_rd.compute_list_bind_uniform_set(compute_list, vertical_set, 0)
		_rd.compute_list_set_push_constant(compute_list, vertical, PUSH_CONSTANT_SIZE)
		_rd.compute_list_dispatch(compute_list, groups_x, groups_y, 1)
		_rd.compute_list_end()


func _uniform_set(source: RID, destination: RID) -> RID:
	var sampled_color: RDUniform = RDUniform.new()
	sampled_color.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	sampled_color.binding = 0
	sampled_color.add_id(_sampler)
	sampled_color.add_id(source)
	var output_color: RDUniform = RDUniform.new()
	output_color.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_color.binding = 1
	output_color.add_id(destination)
	return UniformSetCacheRD.get_cache(_shader, 0, [sampled_color, output_color])


func _push_constants(size: Vector2i, direction: Vector2, spacing: float) -> PackedByteArray:
	return PackedFloat32Array([
		float(size.x), float(size.y), direction.x, direction.y,
		spacing, 0.0, 0.0, 0.0,
	]).to_byte_array()
