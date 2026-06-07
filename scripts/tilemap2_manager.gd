extends TileMapLayer

@export var trampa_p1_scene: PackedScene
@export var bloque_melee_scene: PackedScene
@export var bloque_projectile_scene: PackedScene

var mapa_bloques: Dictionary = {}

func _ready() -> void:
	var celdas_usadas = get_used_cells()
	
	for celda in celdas_usadas:
		var tile_data = get_cell_tile_data(celda)
		
		if tile_data:
			var tipo = tile_data.get_custom_data("tipo_bloque")
			
			if tipo == "melee" and bloque_melee_scene:
				_reemplazar_por_escena(celda, tipo, bloque_melee_scene)
				
			elif tipo == "projectile" and bloque_projectile_scene:
				_reemplazar_por_escena(celda, tipo, bloque_projectile_scene)
			
			elif tipo == "hazard_p1" and trampa_p1_scene:
				_reemplazar_por_escena(celda, tipo, trampa_p1_scene)

func _reemplazar_por_escena(celda: Vector2i, tipo: String, escena: PackedScene) -> void:
	# EL SECRETO: ¡Ya no borramos la celda aquí! 
	# Dejamos que el TileMapLayer siga dibujando la reja con sus esquinas perfectas.
	
	var nuevo_bloque = escena.instantiate()
	nuevo_bloque.global_position = to_global(map_to_local(celda))
	
	# Usamos call_deferred para agregarlo al mundo de forma segura
	get_parent().call_deferred("add_child", nuevo_bloque)
	
	mapa_bloques[celda] = { "nodo": nuevo_bloque, "tipo": tipo }
	
	if nuevo_bloque.has_method("configurar_bloque"):
		nuevo_bloque.configurar_bloque(self, celda, tipo)

# --- ALGORITMO DE REACCIÓN EN CADENA ---
func destruir_grupo_en_cadena(celda_inicial: Vector2i, tipo_buscado: String) -> void:
	var celdas_por_revisar = [celda_inicial]
	var celdas_a_destruir = []
	var visitados = {}
	var direcciones = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	
	while celdas_por_revisar.size() > 0:
		var actual = celdas_por_revisar.pop_back()
		
		if visitados.has(actual):
			continue
		visitados[actual] = true
		
		if mapa_bloques.has(actual):
			var datos = mapa_bloques[actual]
			
			if is_instance_valid(datos["nodo"]) and datos["tipo"] == tipo_buscado:
				celdas_a_destruir.append(actual)
				
				for dir in direcciones:
					var vecino = actual + dir
					if not visitados.has(vecino):
						celdas_por_revisar.append(vecino)
						
	# Aquí ocurre la magia de la destrucción visual y física
	for c in celdas_a_destruir:
		
		# 1. Destruimos el bloque de colisión invisible
		var bloque = mapa_bloques[c]["nodo"]
		if is_instance_valid(bloque):
			bloque.queue_free()
			
		# 2. AHORA SÍ borramos el dibujo exacto de esa celda en el TileMapLayer
		erase_cell(c)
		
		# 3. Lo borramos del registro para limpiar memoria
		mapa_bloques.erase(c)
