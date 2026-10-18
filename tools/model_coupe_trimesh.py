#!/usr/bin/env python3
"""Generate an inspectable Ayo Race coupe model (GLB + OBJ).

This is an offline model-generation tool. The game's runtime remains NASM.
Run after installing numpy and trimesh into a Python virtual environment.
"""
import math
from pathlib import Path
import numpy as np
import trimesh

out = Path(__file__).resolve().parents[1] / "assets" / "models"
out.mkdir(parents=True, exist_ok=True)
scene = trimesh.Scene()
red=[222,24,37,255]
glass=[22,47,70,255]
black=[20,22,26,255]
silver=[173,188,198,255]
lamp=[222,237,238,255]

def add(mesh, name, color):
    mesh.visual.vertex_colors = np.tile(np.array(color,dtype=np.uint8),(len(mesh.vertices),1))
    scene.add_geometry(mesh,geom_name=name)

def ellipsoid(name,center,size,color):
    mesh=trimesh.creation.uv_sphere(radius=1,count=[32,24])
    mesh.apply_scale(size)
    mesh.apply_translation(center)
    add(mesh,name,color)

# Smooth single car shell with true polygonal wheel-arch contours.
# Unlike triangle deletion, the mesh boundary follows the arch curve continuously.
# Coordinates: X = sideways, Y = up, Z = car length.
AXLES = (-1.03, 1.03)
WHEEL_CENTER_Y = 0.38
WHEEL_RADIUS = 0.35
ARCH_RADIUS = 0.43
Z = np.linspace(-1.72, 1.72, 177)

def shell_width(z):
    t = min(abs(z)/1.75, 1.0)
    taper = max(.30, 1.0-t**6)**.32
    shoulders = .045 * sum(math.exp(-((z-v)/.37)**2) for v in AXLES)
    return .96*taper + shoulders

def arch_bottom(z):
    bottom=.245
    for axle in AXLES:
        dz=z-axle
        if abs(dz) < ARCH_RADIUS:
            opening = WHEEL_CENTER_Y+math.sqrt(ARCH_RADIUS**2-dz**2)
            bottom=max(bottom,opening)
    return bottom

verts=[]
faces=[]
def quad(a,b,c,d):
    faces.extend(((a,b,c),(a,c,d)))

def add_grid(rows):
    base=len(verts)
    for row in rows:
        verts.extend(row)
    for i in range(len(rows)-1):
        for j in range(len(rows[0])-1):
            n=len(rows[0])
            a=base+i*n+j
            quad(a,a+n,a+n+1,a+1)

# Upper shoulder, hood and curved upper surface: connected to the two side skins.
top=[]
for z in Z:
    width=shell_width(z)
    row=[]
    for u in np.linspace(-1,1,31):
        x=width*u
        crown=.095*(1-u*u)
        y=.805+crown-.06*(abs(z)/1.75)**4
        row.append((x,y,z))
    top.append(row)
add_grid(top)

# Proper arches are not after-the-fact missing triangles: the lower edge of
# each side panel is the actual semicircular wheel-arch boundary.
for side in (-1,1):
    rows=[]
    for z in Z:
        width=shell_width(z)
        bottom=arch_bottom(z)
        upper=.805-.06*(abs(z)/1.75)**4
        rows.append([(side*width,bottom+(upper-bottom)*u,z)
                     for u in np.linspace(0,1,9)])
    add_grid(rows)

body=trimesh.Trimesh(vertices=np.asarray(verts),faces=np.asarray(faces),
                     process=False)
# Do not invoke fix_normals(): Trimesh may require optional scipy for
# disconnected/open surfaces, and our body deliberately has open wheel arches.
# Face normals are derived by Trimesh from vertex winding when exporting.
add(body,"Sculpted body and real arched side panels",red)

# Painted curved lip above each opening (small radius trim following arch).
for side in (-1,1):
    for axle in AXLES:
        theta=np.linspace(0,math.pi,55)
        path=[]
        for ang in theta:
            z=axle+ARCH_RADIUS*math.cos(ang)
            y=WHEEL_CENTER_Y+ARCH_RADIUS*math.sin(ang)
            path.append((side*(shell_width(z)+.008),y+.015,z))
        for k in range(len(path)-1):
            aa,bb=np.array(path[k]),np.array(path[k+1])
            length=np.linalg.norm(bb-aa)
            if length<1e-7:
                continue
            lip=trimesh.creation.cylinder(radius=.018,height=length,sections=8)
            lip.apply_transform(trimesh.geometry.align_vectors([0,0,1],bb-aa))
            lip.apply_translation((aa+bb)/2)
            add(lip,f"Wheel arch lip {side} {axle} {k}",red)

# Separate glazed surfaces and physical roof pillars.
lower=[(-.52,.74,.61),(.52,.74,.61),(.52,.74,-.90),(-.52,.74,-.90)]
upper=[(-.43,1.11,.14),(.43,1.11,.14),(.44,1.11,-.59),(-.44,1.11,-.59)]
for name,ids in (
    ("Windscreen",(0,1,5,4)),
    ("Rear glass",(3,7,6,2)),
    ("Left window",(0,4,7,3)),
    ("Right window",(1,2,6,5)),
):
    v=lower+upper
    f=((ids[0],ids[1],ids[2]),(ids[0],ids[2],ids[3]))
    add(trimesh.Trimesh(vertices=v,faces=f,process=False),name,glass)
add(trimesh.Trimesh(vertices=upper,faces=[[0,1,2],[0,2,3]],process=False),"Painted roof",red)

def beam(a,b,radius,name):
    a=np.asarray(a); b=np.asarray(b)
    vec=b-a
    mesh=trimesh.creation.cylinder(radius=radius,height=np.linalg.norm(vec),sections=10)
    mesh.apply_transform(trimesh.geometry.align_vectors([0,0,1],vec))
    mesh.apply_translation((a+b)/2)
    add(mesh,name,red)

for i in range(4):
    beam(lower[i],upper[i],.038,f"Cabin pillar {i}")
for i,j in ((0,1),(1,2),(2,3),(3,0)):
    beam(upper[i],upper[j],.03,f"Roof frame {i}-{j}")

for axle,z in (("rear",-1.03),("front",1.03)):
    for side in (-1,1):
        x=side*.83
        rotation=trimesh.transformations.rotation_matrix(math.pi/2,[0,1,0])
        tire=trimesh.creation.cylinder(radius=WHEEL_RADIUS,height=.19,sections=40)
        tire.apply_transform(rotation); tire.apply_translation((x,WHEEL_CENTER_Y,z))
        add(tire,f"{axle} tire {side}",black)
        face=x+side*.102
        rim=trimesh.creation.cylinder(radius=.230,height=.014,sections=40)
        rim.apply_transform(rotation); rim.apply_translation((face,WHEEL_CENTER_Y,z))
        add(rim,f"{axle} alloy rim {side}",silver)
        hub=trimesh.creation.cylinder(radius=.071,height=.018,sections=20)
        hub.apply_transform(rotation); hub.apply_translation((face+side*.015,WHEEL_CENTER_Y,z))
        add(hub,f"{axle} wheel hub {side}",black)

for side in (-1,1):
    ellipsoid(f"Headlight {side}",(side*.56,.66,1.48),(.135,.04,.052),lamp)
    ellipsoid(f"Tail light {side}",(side*.64,.61,-1.52),(.18,.045,.05),[190,12,24,255])

glb=out/"ayo_race_concept.glb"
glb.write_bytes(scene.export(file_type="glb"))
combined=trimesh.util.concatenate(list(scene.geometry.values()))
combined.export(out/"ayo_race_concept.obj")
print(f"Generated {glb} with {len(scene.geometry)} components and {len(combined.faces)} faces")
