import bpy
# Enable Rigify addon
bpy.ops.preferences.addon_enable(module='rigify')
print("Rigify enabled")

# Now try to add metarig
try:
    bpy.ops.object.armature_human_metarig_add()
    print("metarig added successfully")
except Exception as e:
    print(f"metarig add failed: {e}")
    # Try alternative
    try:
        bpy.ops.armature.bone_primitive_add()
        print("bone_primitive_add worked")
    except Exception as e2:
        print(f"bone_primitive_add failed: {e2}")
