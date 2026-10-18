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

# One continuous curved body mesh, with wheel arches opened in its sides.
N=72
zs=np.linspace(-1.71,1.71,69)
vertices=[]
for z in zs:
    t=abs(z)/1.75
    width=.94*(max(.12,1-t**5)**.45)+.045*sum(np.exp(-((z-v)/.37)**2) for v in (-1.03,1.03))
    for angle in np.linspace(0,2*math.pi,N,endpoint=False):
        x=width*np.sign(np.cos(angle))*abs(np.cos(angle))**.73
        y=.50+(.28+.02*sum(np.exp(-((z-v)/.39)**2) for v in (-1.03,1.03)))*np.sign(np.sin(angle))*abs(np.sin(angle))**.76
        vertices.append([x,y,z])

faces=[]
for i in range(len(zs)-1):
    for j in range(N):
        a=i*N+j; b=(i+1)*N+j; c=(i+1)*N+(j+1)%N; d=i*N+(j+1)%N
        for face in ((a,b,c),(a,c,d)):
            centroid=np.asarray([vertices[k] for k in face]).mean(axis=0)
            if abs(centroid[0])>.66 and any(
                ((centroid[2]-axle)/.46)**2+((centroid[1]-.37)/.42)**2<1
                for axle in (-1.03,1.03)
            ):
                continue
            faces.append(face)
body=trimesh.Trimesh(vertices=vertices,faces=faces,process=False)
add(body,"Continuous curved body",red)

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
        x=side*.80
        rotation=trimesh.transformations.rotation_matrix(math.pi/2,[0,1,0])
        tire=trimesh.creation.cylinder(radius=.37,height=.205,sections=40)
        tire.apply_transform(rotation); tire.apply_translation((x,.38,z))
        add(tire,f"{axle} tire {side}",black)
        face=x+side*.108
        rim=trimesh.creation.cylinder(radius=.244,height=.014,sections=40)
        rim.apply_transform(rotation); rim.apply_translation((face,.38,z))
        add(rim,f"{axle} alloy rim {side}",silver)
        hub=trimesh.creation.cylinder(radius=.071,height=.018,sections=20)
        hub.apply_transform(rotation); hub.apply_translation((face+side*.015,.38,z))
        add(hub,f"{axle} wheel hub {side}",black)

for side in (-1,1):
    ellipsoid(f"Headlight {side}",(side*.56,.66,1.48),(.135,.04,.052),lamp)
    ellipsoid(f"Tail light {side}",(side*.64,.61,-1.52),(.18,.045,.05),[190,12,24,255])

glb=out/"ayo_race_concept.glb"
glb.write_bytes(scene.export(file_type="glb"))
combined=trimesh.util.concatenate(list(scene.geometry.values()))
combined.export(out/"ayo_race_concept.obj")
print(f"Generated {glb} with {len(scene.geometry)} components and {len(combined.faces)} faces")
