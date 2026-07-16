import bpy
# List all armature-related operators
ops = [op for op in dir(bpy.ops.object) if 'armature' in op.lower() or 'rig' in op.lower() or 'metarig' in op.lower()]
print("Armature/Rig operators:", ops)
# Also check if Rigify addon is available
try:
    import rigify
    print("Rigify available")
except:
    print("Rigify not available")
# Check addons
for addon in bpy.context.preferences.addons.keys():
    if 'rig' in addon.lower():
        print(f"Addon: {addon}")
