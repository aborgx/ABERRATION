#!/usr/bin/env python3
"""Generate 17 modular prop tscn files for Godot 4."""
import os, secrets

PROPS_DIR = "scenes/props"
os.makedirs(PROPS_DIR, exist_ok=True)

def uid():
    return secrets.token_hex(8)

def write_tscn(name, content):
    path = os.path.join(PROPS_DIR, f"{name}.tscn")
    with open(path, "w") as f:
        f.write(content)
    print(f"  ✓ {path}")

def simple_prop(name, root_type, mesh_type, mesh_params, shape_type, shape_params, extras=""):
    u = uid()
    content = f"""[gd_scene load_steps=3 format=3 uid="uid://{u}"]

[sub_resource type="{mesh_type}" id="Mesh_{name}"]
{mesh_params}

[sub_resource type="{shape_type}" id="Shape_{name}"]
{shape_params}

[node name="{name[0].upper() + name[1:]}" type="{root_type}"]
collision_layer = 2
collision_mask = 1

[node name="Mesh" type="MeshInstance3D" parent="."]
mesh = SubResource("Mesh_{name}")

[node name="Collision" type="CollisionShape3D" parent="."]
shape = SubResource("Shape_{name}")
{extras}
"""
    write_tscn(name, content)

# 1. Wall module
simple_prop("wall_module", "StaticBody3D", "BoxMesh", "size = Vector3(4, 3, 0.2)", "BoxShape3D", "size = Vector3(4, 3, 0.2)")

# 2. Floor module
simple_prop("floor_module", "StaticBody3D", "BoxMesh", "size = Vector3(4, 0.1, 4)", "BoxShape3D", "size = Vector3(4, 0.1, 4)")

# 3. Pillar module
simple_prop("pillar_module", "StaticBody3D", "CylinderMesh", "top_radius = 0.5\nbottom_radius = 0.5\nheight = 3.0", "CylinderShape3D", "radius = 0.5\nheight = 3.0")

# 4. Door module (with trigger)
u = uid()
door_content = f"""[gd_scene load_steps=4 format=3 uid="uid://{u}"]

[sub_resource type="BoxMesh" id="Mesh_door"]
size = Vector3(1.2, 2.5, 0.1)

[sub_resource type="BoxShape3D" id="Shape_door"]
size = Vector3(1.2, 2.5, 0.1)

[sub_resource type="BoxShape3D" id="Trigger_door"]
size = Vector3(2.0, 3.0, 2.0)

[node name="DoorModule" type="StaticBody3D"]
collision_layer = 2
collision_mask = 1

[node name="Mesh" type="MeshInstance3D" parent="."]
mesh = SubResource("Mesh_door")

[node name="Collision" type="CollisionShape3D" parent="."]
shape = SubResource("Shape_door")

[node name="Trigger" type="Area3D" parent="."]
collision_layer = 0
collision_mask = 1

[node name="TriggerShape" type="CollisionShape3D" parent="Trigger"]
shape = SubResource("Trigger_door")
"""
write_tscn("door_module", door_content)

# 5. Window module (breakable glass)
simple_prop("window_module", "StaticBody3D", "BoxMesh", "size = Vector3(1.5, 1.5, 0.05)", "BoxShape3D", "size = Vector3(1.5, 1.5, 0.05)")

# 6. Stairs module
u = uid()
stairs_content = f"""[gd_scene load_steps=3 format=3 uid="uid://{u}"]

[sub_resource type="BoxMesh" id="Mesh_step"]
size = Vector3(1.0, 0.25, 0.5)

[sub_resource type="BoxShape3D" id="Shape_step"]
size = Vector3(1.0, 0.25, 0.5)

[node name="StairsModule" type="StaticBody3D"]
collision_layer = 2
collision_mask = 1

[node name="Step1" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.25, 0)
mesh = SubResource("Mesh_step")

[node name="Step1Col" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.25, 0)
shape = SubResource("Shape_step")

[node name="Step2" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.75, 0.5)
mesh = SubResource("Mesh_step")

[node name="Step2Col" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.75, 0.5)
shape = SubResource("Shape_step")

[node name="Step3" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.25, 1.0)
mesh = SubResource("Mesh_step")

[node name="Step3Col" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.25, 1.0)
shape = SubResource("Shape_step")
"""
write_tscn("stairs_module", stairs_content)

# 7. Corridor module
simple_prop("corridor_module", "StaticBody3D", "BoxMesh", "size = Vector3(2, 3, 8)", "BoxShape3D", "size = Vector3(2, 3, 8)")

# 8. Room module
simple_prop("room_module", "StaticBody3D", "BoxMesh", "size = Vector3(8, 3, 8)", "BoxShape3D", "size = Vector3(8, 3, 8)")

# 9. Barricade prop (destructible)
u = uid()
barricade_content = f"""[gd_scene load_steps=3 format=3 uid="uid://{u}"]

[ext_resource type="Script" path="res://scripts/level/destructible_prop.gd" id="1"]

[sub_resource type="BoxMesh" id="Mesh_barricade"]
size = Vector3(2, 1.5, 0.3)

[sub_resource type="BoxShape3D" id="Shape_barricade"]
size = Vector3(2, 1.5, 0.3)

[node name="BarricadeProp" type="StaticBody3D"]
script = ExtResource("1")
collision_layer = 2
collision_mask = 1
max_health = 150

[node name="Mesh" type="MeshInstance3D" parent="."]
mesh = SubResource("Mesh_barricade")

[node name="Collision" type="CollisionShape3D" parent="."]
shape = SubResource("Shape_barricade")
"""
write_tscn("barricade_prop", barricade_content)

# 10. Turret prop
u = uid()
turret_content = f"""[gd_scene load_steps=4 format=3 uid="uid://{u}"]

[sub_resource type="CylinderMesh" id="Mesh_base"]
top_radius = 0.3
bottom_radius = 0.5
height = 0.5

[sub_resource type="CylinderShape3D" id="Shape_base"]
radius = 0.5
height = 0.5

[sub_resource type="CylinderMesh" id="Mesh_barrel"]
top_radius = 0.05
bottom_radius = 0.08
height = 1.0

[node name="TurretProp" type="StaticBody3D"]
collision_layer = 2
collision_mask = 1

[node name="Base" type="MeshInstance3D" parent="."]
mesh = SubResource("Mesh_base")

[node name="CollisionBase" type="CollisionShape3D" parent="."]
shape = SubResource("Shape_base")

[node name="Barrel" type="MeshInstance3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.3, 0)
mesh = SubResource("Mesh_barrel")
"""
write_tscn("turret_prop", turret_content)

# 11. Tank prop (explosive)
simple_prop("tank_prop", "StaticBody3D", "CylinderMesh", "top_radius = 0.4\nbottom_radius = 0.4\nheight = 0.8", "CylinderShape3D", "radius = 0.4\nheight = 0.8")

# 12. Computer prop
simple_prop("computer_prop", "StaticBody3D", "BoxMesh", "size = Vector3(0.8, 0.6, 0.05)", "BoxShape3D", "size = Vector3(0.8, 0.6, 0.05)")

# 13. Bed prop
simple_prop("bed_prop", "StaticBody3D", "BoxMesh", "size = Vector3(2, 0.5, 1.5)", "BoxShape3D", "size = Vector3(2, 0.5, 1.5)")

# 14. Desk prop
simple_prop("desk_prop", "StaticBody3D", "BoxMesh", "size = Vector3(1.5, 0.8, 0.8)", "BoxShape3D", "size = Vector3(1.5, 0.8, 0.8)")

# 15. Shelf prop
simple_prop("shelf_prop", "StaticBody3D", "BoxMesh", "size = Vector3(1.2, 2, 0.4)", "BoxShape3D", "size = Vector3(1.2, 2, 0.4)")

# 16. Lamp prop (with light)
u = uid()
lamp_content = f"""[gd_scene load_steps=3 format=3 uid="uid://{u}"]

[sub_resource type="CylinderMesh" id="Mesh_pole"]
top_radius = 0.03
bottom_radius = 0.05
height = 2.0

[sub_resource type="SphereShape3D" id="Shape_light"]
radius = 0.1

[node name="LampProp" type="StaticBody3D"]
collision_layer = 2
collision_mask = 1

[node name="Pole" type="MeshInstance3D" parent="."]
mesh = SubResource("Mesh_pole")

[node name="Light" type="OmniLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.0, 0)
omni_range = 8.0
light_energy = 0.8
light_color = Color(1, 0.95, 0.8)

[node name="LightCollision" type="CollisionShape3D" parent="Light"]
shape = SubResource("Shape_light")
"""
write_tscn("lamp_prop", lamp_content)

# 17. PropLibrary.gd
prop_library = """class_name PropLibrary
extends Node
## Registry for all modular level props.
## Provides lookup by type string for procedural level generation.

var prop_scenes: Dictionary = {
	"wall": preload("res://scenes/props/wall_module.tscn"),
	"floor": preload("res://scenes/props/floor_module.tscn"),
	"pillar": preload("res://scenes/props/pillar_module.tscn"),
	"door": preload("res://scenes/props/door_module.tscn"),
	"window": preload("res://scenes/props/window_module.tscn"),
	"stairs": preload("res://scenes/props/stairs_module.tscn"),
	"corridor": preload("res://scenes/props/corridor_module.tscn"),
	"room": preload("res://scenes/props/room_module.tscn"),
	"barricade": preload("res://scenes/props/barricade_prop.tscn"),
	"turret": preload("res://scenes/props/turret_prop.tscn"),
	"tank": preload("res://scenes/props/tank_prop.tscn"),
	"computer": preload("res://scenes/props/computer_prop.tscn"),
	"bed": preload("res://scenes/props/bed_prop.tscn"),
	"desk": preload("res://scenes/props/desk_prop.tscn"),
	"shelf": preload("res://scenes/props/shelf_prop.tscn"),
	"lamp": preload("res://scenes/props/lamp_prop.tscn"),
}

func get_prop(prop_type: String) -> PackedScene:
	if prop_scenes.has(prop_type):
		return prop_scenes[prop_type]
	return null

func get_all_types() -> Array[String]:
	return prop_scenes.keys()

func instantiate_prop(prop_type: String) -> Node3D:
	var scene = get_prop(prop_type)
	if scene:
		return scene.instantiate()
	return null
"""
with open("scripts/level/prop_library.gd", "w") as f:
    f.write(prop_library)
print("  ✓ scripts/level/prop_library.gd")

print(f"\nDone: {len(os.listdir(PROPS_DIR))} prop files + prop_library.gd")
