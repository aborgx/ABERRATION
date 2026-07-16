import bpy
# Check armature operators
ops_armature = [op for op in dir(bpy.ops.armature) if 'rig' in op.lower() or 'human' in op.lower() or 'metarig' in op.lower()]
print("bpy.ops.armature operators:", ops_armature)
# Check all armature-related
all_ops = [op for op in dir(bpy.ops.armature)]
print("All bpy.ops.armature:", all_ops)
