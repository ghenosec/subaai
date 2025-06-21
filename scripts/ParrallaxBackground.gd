extends ParallaxBackground

@export var background_size: Vector2 = Vector2(1920, 1080)
@export var tile_background: bool = true

func _ready():
	configure_layers()

func configure_layers():
	for child in get_children():
		if child is ParallaxLayer:
			var layer = child as ParallaxLayer
			
			for sprite_child in layer.get_children():
				if sprite_child is Sprite2D:
					var sprite = sprite_child as Sprite2D
					if sprite.texture:
						var texture_size = sprite.texture.get_size()
						
						if tile_background:
							layer.motion_mirroring = Vector2(texture_size.x, texture_size.y)
							print("Mirroring configurado: ", layer.motion_mirroring)
						
						layer.motion_scale = Vector2(0.9, 0.9) 
						
						sprite.centered = true
						sprite.position = Vector2.ZERO
						
						print("Layer configurada: ", layer.name)
						print("- Texture size: ", texture_size)
						print("- Motion scale: ", layer.motion_scale)
