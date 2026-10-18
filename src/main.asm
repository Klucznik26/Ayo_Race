default rel
global main

; Generated before NASM runs by tools/generate_car.py.
%include "build/car_mesh.inc"

extern SDL_Init, SDL_Quit, SDL_CreateWindow, SDL_DestroyWindow
extern SDL_GL_CreateContext, SDL_GL_DeleteContext, SDL_GL_SwapWindow
extern SDL_GL_SetSwapInterval, SDL_GL_SetAttribute, SDL_PollEvent, SDL_Delay, SDL_GetError
extern glClearColor, glClear, glViewport, glEnable, glDisable, glShadeModel
extern glColorMaterial, glMaterialfv, glMaterialf, glLightfv
extern glMatrixMode, glLoadIdentity, glPushMatrix, glPopMatrix, glMultMatrixf
extern glTranslatef, glRotatef, glScalef, glColor3f
extern glVertexPointer, glNormalPointer, glEnableClientState, glDrawArrays
extern glBegin, glEnd, glVertex3f, glVertex3fv, glLineWidth
extern gluPerspective, gluLookAt, gluNewQuadric, gluSphere, gluCylinder, gluDisk
extern sin, cos, atan2, printf

%define SDL_INIT_VIDEO 0x20
%define SDL_WINDOW_OPENGL 2
%define SDL_GL_MULTISAMPLEBUFFERS 13
%define SDL_GL_MULTISAMPLESAMPLES 14
%define SDL_WINDOW_SHOWN 4
%define SDL_QUIT 0x100
%define SDL_KEYDOWN 0x300
%define GL_COLOR_BUFFER_BIT 0x4000
%define GL_DEPTH_BUFFER_BIT 0x0100
%define GL_DEPTH_TEST 0x0b71
%define GL_LIGHTING 0x0b50
%define GL_LIGHT0 0x4000
%define GL_NORMALIZE 0x0BA1
%define GL_AMBIENT 0x1200
%define GL_DIFFUSE 0x1201
%define GL_COLOR_MATERIAL 0x0b57
%define GL_FRONT_AND_BACK 0x0408
%define GL_AMBIENT_AND_DIFFUSE 0x1602
%define GL_POSITION 0x1203
%define GL_SPECULAR 0x1202
%define GL_SHININESS 0x1601
%define GL_PROJECTION 0x1701
%define GL_MODELVIEW 0x1700
%define GL_VERTEX_ARRAY 0x8074
%define GL_NORMAL_ARRAY 0x8075
%define GL_FLOAT 0x1406
%define GL_QUADS 7
%define GL_TRIANGLES 4
%define GL_LINES 1
%define GL_QUAD_STRIP 8
%define GL_LINE_LOOP 2

section .rodata align=16
caption db "Ayo Race 0.1 — ASM 3D Demo | Esc: exit",0
error_fmt db "SDL error: %s",10,0
f_zero dd 0.0
f_one dd 1.0
f_red dd 0.85,0.018,0.035
f_white dd 0.97
f_black dd 0.025
f_glass dd 0.09,0.28,0.40
f_blue_stripe dd 0.035,0.20,0.91
f_gold dd 0.92,0.68,0.12
f_tire dd 0.05,0.05,0.06
f_stripe dd 0.97,0.96,0.89
f_lamp dd 0.99,0.91,0.44
f_rim dd 0.78,0.84,0.93
f_hub dd 0.22,0.24,0.30
f_brake dd 0.12,0.12,0.14
wheel_90 dd 90.0
wheel_180 dd 180.0
wheel_radius dq 0.33
wheel_inner dq 0.18
wheel_hub_radius dq 0.075
wheel_width dq 0.30
wheel_face_offset dd 0.335
wheel_back_offset dd -0.035
f_roof dd 0.08,0.13,0.19
f_wood dd 0.44,0.26,0.13
f_sky dd 0.64,0.81,0.98,1.0
light_pos dd -5.0,12.0,6.0,1.0
light_diffuse dd 0.94,0.90,0.84,1.0
light_ambient dd 0.32,0.34,0.38,1.0
specular dd 0.48,0.48,0.50,1.0
shininess dd 85.0
aspect dq 1.77777777777778
fovy dq 48.0
near_z dq 0.1
far_z dq 100.0
eye_x dq 0.0
eye_y dq 15.5
eye_z dq 18.5
target_x dq 0.0
target_y dq 0.0
target_z dq 0.0
up_x dq 0.0
up_y dq 1.0
up_z dq 0.0
twopi dq 6.283185307179586
pi_over_180 dq 57.29577951308232
step_angle dq 0.0090
road_outer_x dq 10.2
road_outer_z dq 4.6
road_inner_x dq 7.6
road_inner_z dq 2.2
path_x dq 8.9
path_z dq 3.4
road_edge_x dq 10.0
road_edge_z dq 4.43
road_inner_line_x dq 7.8
road_inner_line_z dq 2.37
road_lane_x dq 8.9
road_lane_z dq 3.4
unit_x dq 1.0
half_turn dq 3.141592653589793
neg_one dd -1.0
zero_d dq 0.0
ground_scale dd 23.0,0.12,15.0
car_body_scale dd 0.82,0.21,1.30
car_cabin_scale dd 0.56,0.24,0.60
spoiler_scale dd 0.78,0.055,0.17
wheel_size dq 0.37
unit_sphere_radius dq 1.0
f_rearlamp dd 0.95,0.06,0.07
car_body dd 0.0000, 0.4800, 0.0000, 0.9850, 0.2600, 1.4800
car_nose dd 0.0000, 0.4550, 1.1500, 0.9000, 0.2000, 0.4800
car_tail dd 0.0000, 0.4950, -1.1250, 0.9000, 0.2500, 0.4800
car_hood dd 0.0000, 0.6200, 0.7950, 0.7300, 0.1050, 0.6550
; Low painted roof, distinct glass panes and painted A/B/C pillars.
; Cabin: distinct flat glazing panels, painted roof and A/B/C posts.
; Each glass quad comprises four XYZ float triplets (GL_QUADS order).
glass_front:
 dd -0.49,0.76,0.57,  0.49,0.76,0.57,  0.44,1.08,0.24, -0.44,1.08,0.24
glass_rear:
 dd  0.45,0.76,-0.85, -0.45,0.76,-0.85, -0.43,1.08,-0.62, 0.43,1.08,-0.62
glass_left:
 dd -0.54,0.77,-0.80, -0.54,0.77,0.54, -0.47,1.08,0.21, -0.47,1.08,-0.59
glass_right:
 dd 0.54,0.77,0.54, 0.54,0.77,-0.80, 0.47,1.08,-0.59, 0.47,1.08,0.21
car_roof dd 0.0000,1.1000,-0.1900,0.5350,0.0950,0.4950
; Structured low coupe cabin: actual flat roof, sloped windshield,
; and separate side windows. No roof/sill/pillar spheres.
cabin_roof_panel:
 dd -0.445,1.135,0.16,  0.445,1.135,0.16,  0.445,1.135,-0.62, -0.445,1.135,-0.62
cabin_windshield_panel:
 dd -0.49,0.745,0.59,  0.49,0.745,0.59,  0.425,1.122,0.17, -0.425,1.122,0.17
cabin_rear_panel:
 dd -0.455,0.77,-0.91,  -0.425,1.122,-0.62,  0.425,1.122,-0.62,  0.455,0.77,-0.91
cabin_left_panel:
 dd -0.49,0.785,0.53, -0.49,0.785,-0.86, -0.425,1.122,-0.62, -0.425,1.122,0.16
cabin_right_panel:
 dd 0.49,0.785,-0.86, 0.49,0.785,0.53, 0.425,1.122,0.16, 0.425,1.122,-0.62
; Pillar segments are actual linear braces (not ellipsoids).
cabin_pillars:
 dd -0.50,0.77,0.59, -0.445,1.14,0.17
 dd  0.50,0.77,0.59,  0.445,1.14,0.17
 dd -0.50,0.78,-0.23, -0.445,1.14,-0.23
 dd  0.50,0.78,-0.23,  0.445,1.14,-0.23
 dd -0.49,0.78,-0.88, -0.445,1.14,-0.62
 dd  0.49,0.78,-0.88,  0.445,1.14,-0.62
 ; windshield rim connecting roof and hood
 dd -0.50,0.77,0.59, 0.50,0.77,0.59
 dd -0.445,1.14,0.17, 0.445,1.14,0.17
 ; rear glass lower edge and roof rear edge
 dd -0.49,0.78,-0.88, 0.49,0.78,-0.88
 dd -0.445,1.14,-0.62, 0.445,1.14,-0.62
 ; left/right longitudinal roof rails
 dd -0.445,1.14,0.17, -0.445,1.14,-0.62
 dd 0.445,1.14,0.17, 0.445,1.14,-0.62

; Narrow blue longitudinal racing stripe on hood, painted roof and rear.
car_stripe_hood dd 0.0000,0.7100,0.8200,0.1550,0.0200,0.5950
car_stripe_roof dd 0.0000,1.2010,-0.1900,0.1450,0.0090,0.3950
car_stripe_rear dd 0.0000,0.7590,-1.1700,0.1500,0.0150,0.3500
car_apillarL dd -0.5000,0.9250,0.3650,0.0640,0.2150,0.2150
car_apillarR dd  0.5000,0.9250,0.3650,0.0640,0.2150,0.2150
car_bpillarL dd -0.5230,0.9240,-0.2700,0.0570,0.2130,0.0780
car_bpillarR dd  0.5230,0.9240,-0.2700,0.0570,0.2130,0.0780
car_cpillarL dd -0.5050,0.9240,-0.7100,0.0800,0.2130,0.1550
car_cpillarR dd  0.5050,0.9240,-0.7100,0.0800,0.2130,0.1550
car_lfender dd -0.7550, 0.4950, 1.0500, 0.2400, 0.2300, 0.4450
car_rfender dd 0.7550, 0.4950, 1.0500, 0.2400, 0.2300, 0.4450
car_lrear dd -0.7550, 0.5000, -1.0500, 0.2450, 0.2350, 0.4450
car_rrear dd 0.7550, 0.5000, -1.0500, 0.2450, 0.2350, 0.4450
car_headL dd -0.5600, 0.6300, 1.5300, 0.1450, 0.1050, 0.1200
car_headR dd 0.5600, 0.6300, 1.5300, 0.1450, 0.1050, 0.1200
car_tailL dd -0.5800, 0.6100, -1.5300, 0.1700, 0.0950, 0.1000
car_tailR dd 0.5800, 0.6100, -1.5300, 0.1700, 0.0950, 0.1000

; 24 independent vertices, six cube faces with corresponding normals
cube_vertices:
dd -1.0,-1.0, 1.0,  1.0,-1.0, 1.0,  1.0, 1.0, 1.0, -1.0, 1.0, 1.0
dd  1.0,-1.0,-1.0, -1.0,-1.0,-1.0, -1.0, 1.0,-1.0,  1.0, 1.0,-1.0
dd -1.0,-1.0,-1.0, -1.0,-1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0,-1.0
dd  1.0,-1.0, 1.0,  1.0,-1.0,-1.0,  1.0, 1.0,-1.0,  1.0, 1.0, 1.0
dd -1.0, 1.0, 1.0,  1.0, 1.0, 1.0,  1.0, 1.0,-1.0, -1.0, 1.0,-1.0
dd -1.0,-1.0,-1.0,  1.0,-1.0,-1.0,  1.0,-1.0, 1.0, -1.0,-1.0, 1.0
cube_normals:
times 4 dd 0.0,0.0,1.0
times 4 dd 0.0,0.0,-1.0
times 4 dd -1.0,0.0,0.0
times 4 dd 1.0,0.0,0.0
times 4 dd 0.0,1.0,0.0
times 4 dd 0.0,-1.0,0.0

section .bss align=16
window resq 1
context resq 1
quadric resq 1
event resb 64
angle resq 1
tvalue resq 1
sx resq 1
cz resq 1
cos_x resq 1
yaw resd 1
yaw_rad resq 1
align 16
yaw_matrix: resd 16
carx resd 1
carz resd 1
tmpx resd 1
tmpz resd 1

section .text

; glColor3f from packed RGB floats at RDI
set_rgb:
    movss xmm0,[rdi]
    movss xmm1,[rdi+4]
    movss xmm2,[rdi+8]
    jmp glColor3f

; draw unit cube centered on origin
cube:
    mov edi, GL_QUADS
    xor esi,esi
    mov edx,24
    jmp glDrawArrays

; draw a flat horizontal XZ ring with 96 segments
track:
    sub rsp,8                  ; align stack before external GL calls
    lea rdi,[f_black]
    movss xmm0,[rdi]
    movss xmm1,[rdi]
    movss xmm2,[rdi]
    call glColor3f
    mov edi,GL_QUAD_STRIP
    call glBegin
    xor r12d,r12d
.loop:
    cmp r12d,96
    ja .end
    cvtsi2sd xmm0,r12d
    mulsd xmm0,[twopi]
    mov eax,96
    cvtsi2sd xmm1,eax
    divsd xmm0,xmm1
    movsd [tvalue],xmm0
    call cos
    movsd [cos_x],xmm0
    movsd xmm0,[tvalue]
    call sin
    movsd [sx],xmm0
    movsd xmm0,[cos_x]
    mulsd xmm0,[road_outer_x]
    cvtsd2ss xmm0,xmm0
    movss xmm1,[f_zero]
    movsd xmm2,[sx]
    mulsd xmm2,[road_outer_z]
    cvtsd2ss xmm2,xmm2
    call glVertex3f
    movsd xmm0,[cos_x]
    mulsd xmm0,[road_inner_x]
    cvtsd2ss xmm0,xmm0
    movss xmm1,[f_zero]
    movsd xmm2,[sx]
    mulsd xmm2,[road_inner_z]
    cvtsd2ss xmm2,xmm2
    call glVertex3f
    inc r12d
    jmp .loop
.end:
    call glEnd
    ; painted white lines on both sides of black asphalt
    movsd xmm0,[road_edge_x]
    movsd xmm1,[road_edge_z]
    call white_loop
    movsd xmm0,[road_inner_line_x]
    movsd xmm1,[road_inner_line_z]
    call white_loop
    add rsp,8
    ret

; XMM0 = ellipse radius X (double), XMM1 = radius Z
white_loop:
    sub rsp,24
    movsd [rsp],xmm0
    movsd [rsp+8],xmm1
    lea rdi,[f_white]
    movss xmm0,[rdi]
    movss xmm1,[rdi]
    movss xmm2,[rdi]
    call glColor3f
    mov dword [tmpx],0x40800000
    movss xmm0,[tmpx]
    call glLineWidth
    mov edi,GL_LINE_LOOP
    call glBegin
    xor r13d,r13d
.loop:
    cmp r13d,96
    je .end
    cvtsi2sd xmm0,r13d
    mulsd xmm0,[twopi]
    mov eax,96
    cvtsi2sd xmm1,eax
    divsd xmm0,xmm1
    movsd [tvalue],xmm0
    call cos
    movsd [cos_x],xmm0
    movsd xmm0,[tvalue]
    call sin
    mulsd xmm0,[rsp+8]
    cvtsd2ss xmm2,xmm0
    movsd xmm0,[cos_x]
    mulsd xmm0,[rsp]
    cvtsd2ss xmm0,xmm0
    mov dword [tmpx],0x3dcccccd
    movss xmm1,[tmpx]
    call glVertex3f
    inc r13d
    jmp .loop
.end:
    call glEnd
    add rsp,24
    ret

; RDI = scale triple, no other arguments
scale3:
    movss xmm0,[rdi]
    movss xmm1,[rdi+4]
    movss xmm2,[rdi+8]
    jmp glScalef

; Rounded component: RDI -> six floats (position XYZ, scale XYZ),
; RSI -> RGB floats. Geometry is a scaled unit sphere.
; System V AMD64: preserve RBX/R12 and 16-byte stack alignment.
draw_car_ellipsoid:
    push rbx
    push r12
    sub rsp,8
    mov rbx,rdi
    mov r12,rsi
    call glPushMatrix
    movss xmm0,[rbx]
    movss xmm1,[rbx+4]
    movss xmm2,[rbx+8]
    call glTranslatef
    movss xmm0,[rbx+12]
    movss xmm1,[rbx+16]
    movss xmm2,[rbx+20]
    call glScalef
    mov rdi,r12
    call set_rgb
    mov rdi,[quadric]
    movsd xmm0,[unit_sphere_radius]
    mov esi,24
    mov edx,16
    call gluSphere
    call glPopMatrix
    add rsp,8
    pop r12
    pop rbx
    ret

; Paint one quadrilateral mesh, 4 vertices x 3 floats; RDI vertices, RSI RGB.
draw_cabin_quad:
    push rbx
    push r12
    sub rsp,8
    mov rbx,rdi
    mov r12,rsi
    mov rdi,r12
    call set_rgb
    mov edi,GL_QUADS
    call glBegin
    mov rdi,rbx
    call glVertex3fv
    lea rdi,[rbx+12]
    call glVertex3fv
    lea rdi,[rbx+24]
    call glVertex3fv
    lea rdi,[rbx+36]
    call glVertex3fv
    call glEnd
    add rsp,8
    pop r12
    pop rbx
    ret

; All world geometry from simple meshes; stylized sports car facing local +Z
car:
    sub rsp,8
    call glPushMatrix
    movss xmm0,[carx]
    movss xmm1,[f_zero]
    movss xmm2,[carz]
    call glTranslatef
    ; Explicit column-major rotation around global UP axis (Y).
    ; Rotation matrix:
    ; [ cos 0 sin 0 ]
    ; [  0  1  0  0 ]
    ; [-sin 0 cos 0 ]
    ; [  0  0  0  1 ]
    ; This makes pitching/rolling physically impossible regardless of camera.
    movsd xmm0,[yaw_rad]
    call cos
    cvtsd2ss xmm0,xmm0
    movss [yaw_matrix+0],xmm0
    movss [yaw_matrix+40],xmm0
    movsd xmm0,[yaw_rad]
    call sin
    cvtsd2ss xmm0,xmm0
    movss [yaw_matrix+32],xmm0
    xorps xmm0,[sign_float]
    movss [yaw_matrix+8],xmm0
    lea rdi,[yaw_matrix]
    call glMultMatrixf
    ; Continuous body triangulation: eliminates seams/interpenetrating ellipsoids.
    lea rdi,[f_red]
    call set_rgb
    mov edi,3
    mov esi,GL_FLOAT
    xor edx,edx
    lea rcx,[car_mesh_vertices]
    call glVertexPointer
    mov edi,GL_FLOAT
    xor esi,esi
    lea rdx,[car_mesh_normals]
    call glNormalPointer
    mov edi,GL_TRIANGLES
    xor esi,esi
    mov edx,CAR_MESH_VERTEX_COUNT
    call glDrawArrays
    ; Restore pointers so tabletop / other cube geometry stays unaffected.
    mov edi,3
    mov esi,GL_FLOAT
    xor edx,edx
    lea rcx,[cube_vertices]
    call glVertexPointer
    mov edi,GL_FLOAT
    xor esi,esi
    lea rdx,[cube_normals]
    call glNormalPointer
    ; Roof and glazed cabin as real polygon surfaces, not floating bubbles.
    ; Keep glazing and frame unlit for consistent tint across camera angles.
    mov edi,GL_LIGHTING
    call glDisable
    lea rdi,[cabin_windshield_panel]
    lea rsi,[f_glass]
    call draw_cabin_quad
    lea rdi,[cabin_rear_panel]
    lea rsi,[f_glass]
    call draw_cabin_quad
    lea rdi,[cabin_left_panel]
    lea rsi,[f_glass]
    call draw_cabin_quad
    lea rdi,[cabin_right_panel]
    lea rsi,[f_glass]
    call draw_cabin_quad
    lea rdi,[cabin_roof_panel]
    lea rsi,[f_red]
    call draw_cabin_quad
    lea rdi,[f_red]
    call set_rgb
    mov dword [tmpx],0x40000000  ; thin window frame 2px
    movss xmm0,[tmpx]
    call glLineWidth
    mov edi,GL_LINES
    call glBegin
    lea rbx,[cabin_pillars]
%assign ii 0
%rep 24
    lea rdi,[rbx+ii*12]
    call glVertex3fv
%assign ii ii+1
%endrep
    call glEnd
    mov edi,GL_LIGHTING
    call glEnable
    ; Fender shoulders are integral to the generated body mesh.
    lea rdi,[car_headL]
    lea rsi,[f_lamp]
    call draw_car_ellipsoid
    lea rdi,[car_headR]
    lea rsi,[f_lamp]
    call draw_car_ellipsoid
    lea rdi,[car_tailL]
    lea rsi,[f_rearlamp]
    call draw_car_ellipsoid
    lea rdi,[car_tailR]
    lea rsi,[f_rearlamp]
    call draw_car_ellipsoid
    ; Four round wheels, mounted along local X axle.
    ; The tires are cylinders and the alloy wheels are concentric disks.
    xor r14d,r14d
.wheels:
    cmp r14d,4
    je .done
    call glPushMatrix
    test r14d,1
    jz .left
    mov dword [tmpx],0x3f23d70a    ; right wheel starts x=+0.64
    jmp .xset
.left:
    mov dword [tmpx],0xbf70a3d7   ; left wheel starts x=-0.94
.xset:
    cmp r14d,2
    jb .back
    mov dword [tmpz],0x3f866666   ; front axle z=+1.05
    jmp .zset
.back:
    mov dword [tmpz],0xbf866666   ; rear axle z=-1.05
.zset:
    movss xmm0,[tmpx]
    mov dword [tmpx],0x3ed70a3d   ; wheel center y=0.42
    movss xmm1,[tmpx]
    movss xmm2,[tmpz]
    call glTranslatef
    ; GLU cylinder extends in local +Z, rotate onto car's local +X.
    movss xmm0,[wheel_90]
    movss xmm1,[f_zero]
    movss xmm2,[f_one]
    movss xmm3,[f_zero]
    call glRotatef
    lea rdi,[f_tire]
    call set_rgb
    mov rdi,[quadric]
    movsd xmm0,[wheel_radius]
    movsd xmm1,[wheel_radius]
    movsd xmm2,[wheel_width]
    mov esi,24
    mov edx,1
    call gluCylinder
    ; Do not draw the coplanar GLU tire end disks: they interfered with
    ; the metallic hub meshes and caused flickering as the car moved.
    ; Convex alloy wheel faces: unlike flat GLU disks, these have depth and
    ; stay visible from both near/far camera views with depth test enabled.
    ; Local wheel axis is Z after rotating car-local X onto GLU cylinder Z.
    lea rdi,[f_rim]
    call set_rgb
    call glPushMatrix
    movss xmm0,[f_zero]
    movss xmm1,[f_zero]
    mov dword [tmpx],0xbd23d70a     ; left face inset z=-0.04
    movss xmm2,[tmpx]
    call glTranslatef
    movss xmm0,[f_one]
    movss xmm1,[f_one]
    mov dword [tmpx],0x3dcccccd     ; 0.10 depth scale
    movss xmm2,[tmpx]
    call glScalef
    mov rdi,[quadric]
    movsd xmm0,[wheel_inner]
    mov esi,24
    mov edx,12
    call gluSphere
    call glPopMatrix

    lea rdi,[f_rim]
    call set_rgb
    call glPushMatrix
    movss xmm0,[f_zero]
    movss xmm1,[f_zero]
    mov dword [tmpx],0x3eae147b     ; right face z=0.34
    movss xmm2,[tmpx]
    call glTranslatef
    movss xmm0,[f_one]
    movss xmm1,[f_one]
    mov dword [tmpx],0x3dcccccd
    movss xmm2,[tmpx]
    call glScalef
    mov rdi,[quadric]
    movsd xmm0,[wheel_inner]
    mov esi,24
    mov edx,12
    call gluSphere
    call glPopMatrix
    call glPopMatrix
    inc r14d
    jmp .wheels
.done:
    call glPopMatrix
    add rsp,8
    ret

; Calculate x/z and heading for a car on elliptical loop.
move_car:
    sub rsp,8
    movsd xmm0,[angle]
    call cos
    mulsd xmm0,[path_x]
    cvtsd2ss xmm0,xmm0
    movss [carx],xmm0
    movsd xmm0,[angle]
    call sin
    mulsd xmm0,[path_z]
    cvtsd2ss xmm0,xmm0
    movss [carz],xmm0
    ; tangent (dx/dt, dz/dt) = (-rx sin(t), rz cos(t))
    movsd xmm0,[angle]
    call sin
    mulsd xmm0,[path_x]
    xorpd xmm0,[sign_double]
    movsd [sx],xmm0
    movsd xmm0,[angle]
    call cos
    mulsd xmm0,[path_z]
    movapd xmm1,xmm0
    movsd xmm0,[sx]
    call atan2
    movsd [yaw_rad],xmm0
    mulsd xmm0,[pi_over_180]
    cvtsd2ss xmm0,xmm0
    movss [yaw],xmm0
    movsd xmm0,[angle]
    addsd xmm0,[step_angle]
    ucomisd xmm0,[twopi]
    jb .store
    subsd xmm0,[twopi]
.store:
    movsd [angle],xmm0
    add rsp,8
    ret

scene:
    sub rsp,8
    mov edi,GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT
    call glClear
    mov edi,GL_MODELVIEW
    call glMatrixMode
    call glLoadIdentity
    movsd xmm0,[eye_x]
    movsd xmm1,[eye_y]
    movsd xmm2,[eye_z]
    movsd xmm3,[target_x]
    movsd xmm4,[target_y]
    movsd xmm5,[target_z]
    movsd xmm6,[up_x]
    movsd xmm7,[up_y]
    sub rsp,16
    mov rax,[up_z]
    mov [rsp],rax
    call gluLookAt
    add rsp,16
    mov edi,GL_LIGHT0
    mov esi,GL_POSITION
    lea rdx,[light_pos]
    call glLightfv
    ; unlit table and painted track
    mov edi,GL_LIGHTING
    call glDisable
    call glPushMatrix
    movss xmm0,[f_zero]
    mov dword [tmpx],0xbec28f5c ; -0.38
    movss xmm1,[tmpx]
    movss xmm2,[f_zero]
    call glTranslatef
    lea rdi,[ground_scale]
    call scale3
    lea rdi,[f_wood]
    call set_rgb
    call cube
    call glPopMatrix
    call track
    ; Keep track/table unlit, but shade the 3D car using sphere normals.
    mov edi,GL_LIGHTING
    call glEnable
    call move_car
    call car
    mov edi,GL_LIGHTING
    call glDisable
    add rsp,8
    ret

main:
    push rbp
    mov rbp,rsp
    push rbx
    push r12
    push r13
    push r14                  ; stack 16-byte aligned after 5 pushes
    mov edi,SDL_INIT_VIDEO
    call SDL_Init
    test eax,eax
    js .fail
    ; Request 4x MSAA to reduce jaggies on the tiny car and wheel spokes.
    mov edi,SDL_GL_MULTISAMPLEBUFFERS
    mov esi,1
    call SDL_GL_SetAttribute
    mov edi,SDL_GL_MULTISAMPLESAMPLES
    mov esi,4
    call SDL_GL_SetAttribute
    lea rdi,[caption]
    mov esi,0x2fff0000
    mov edx,0x2fff0000
    mov ecx,1280
    mov r8d,720
    mov r9d,SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN
    call SDL_CreateWindow
    test rax,rax
    jz .fail
    mov [window],rax
    mov rdi,rax
    call SDL_GL_CreateContext
    test rax,rax
    jz .fail
    mov [context],rax
    mov edi,1
    call SDL_GL_SetSwapInterval
    mov edi,0
    mov esi,0
    mov edx,1280
    mov ecx,720
    call glViewport
    movss xmm0,[f_sky]
    movss xmm1,[f_sky+4]
    movss xmm2,[f_sky+8]
    movss xmm3,[f_sky+12]
    call glClearColor
    mov edi,GL_DEPTH_TEST
    call glEnable
    ; All body parts are nonuniformly scaled spheres; renormalize their normals.
    mov edi,GL_NORMALIZE
    call glEnable
    mov edi,GL_LIGHTING
    call glEnable
    mov edi,GL_LIGHT0
    call glEnable
    mov edi,GL_COLOR_MATERIAL
    call glEnable
    mov edi,GL_FRONT_AND_BACK
    mov esi,GL_AMBIENT_AND_DIFFUSE
    call glColorMaterial
    mov edi,GL_FRONT_AND_BACK
    mov esi,GL_SPECULAR
    lea rdx,[specular]
    call glMaterialfv
    mov edi,GL_FRONT_AND_BACK
    mov esi,GL_SHININESS
    movss xmm0,[shininess]
    call glMaterialf
    mov edi,GL_LIGHT0
    mov esi,GL_AMBIENT
    lea rdx,[light_ambient]
    call glLightfv
    mov edi,GL_LIGHT0
    mov esi,GL_DIFFUSE
    lea rdx,[light_diffuse]
    call glLightfv
    mov edi,GL_PROJECTION
    call glMatrixMode
    call glLoadIdentity
    movsd xmm0,[fovy]
    movsd xmm1,[aspect]
    movsd xmm2,[near_z]
    movsd xmm3,[far_z]
    call gluPerspective
    mov edi,GL_MODELVIEW
    call glMatrixMode
    mov edi,GL_VERTEX_ARRAY
    call glEnableClientState
    mov edi,GL_NORMAL_ARRAY
    call glEnableClientState
    mov edi,3
    mov esi,GL_FLOAT
    xor edx,edx
    lea rcx,[cube_vertices]
    call glVertexPointer
    mov edi,GL_FLOAT
    xor esi,esi
    lea rdx,[cube_normals]
    call glNormalPointer
    call gluNewQuadric
    mov [quadric],rax
    ; Y-axis yaw matrix, identity terms never vary
    mov dword [yaw_matrix+20],0x3f800000
    mov dword [yaw_matrix+60],0x3f800000
.loop:
    lea rdi,[event]
    call SDL_PollEvent
    test eax,eax
    jz .frame
    mov eax,[event]
    cmp eax,SDL_QUIT
    je .quit
    cmp eax,SDL_KEYDOWN
    jne .loop
    cmp dword [event+20],27
    je .quit
    jmp .loop
.frame:
    call scene
    mov rdi,[window]
    call SDL_GL_SwapWindow
    mov edi,16
    call SDL_Delay
    jmp .loop
.quit:
    mov rdi,[context]
    call SDL_GL_DeleteContext
    mov rdi,[window]
    call SDL_DestroyWindow
    call SDL_Quit
    xor eax,eax
    jmp .ret
.fail:
    call SDL_GetError
    lea rdi,[error_fmt]
    mov rsi,rax
    xor eax,eax
    call printf
    mov eax,1
.ret:
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

section .rodata
align 16
sign_double dq 0x8000000000000000
align 16
sign_float dd 0x80000000,0,0,0
section .note.GNU-stack noalloc noexec nowrite progbits
