-- GLOBAL CONSTANTS

-- catagories for items of ode - for identifing what things interact with other items
category_world = 4
category_ball = 2
category_flipper = 8
category_all = category_world + category_ball + category_flipper

-- Position of camera
camera_x = 0
camera_y = 300--27--15--170
camera_z = 0--30--200--200
camera_turn_x = -90---45---2---45
camera_turn_y = 0 --not used
camera_turn_z = 0 --not used
cam = true

-- Position of light
light_x = 0.0
light_y = 60.0
light_z = 0.0--50.0

-- Scaling constant (distance units per cm)
--scale = 1.43163923

-- Ball attributes
ball = nil
ball_r = 1.5
ball_m = .160
ball_bounce = 1
ball_friction = 0
ball_erp = .2
ball_cfm = 0.01

-- Table attributes
table_l = 200 --27.5 in
table_w = 100 --55 in
wall_h = ball_r * 2
wall_th = 5
table_friction = 1000
wall_bounce = 1
wall_friction = 10

-- Initial position of the ball
ball_i_x = math.random(-table_w/2+ball_r, table_w/2-ball_r)
ball_i_y = 0.83457559347153 --* ball_r / 1.5
ball_i_z = math.random(-table_l/2-ball_r, 0)

-- Position of the mouse
mouse_X = 0
mouse_Y = 0

-- A variable to determine if the ball has been launched yet
before_launch = true
launch_count = 0

-- Flippers
flipper_right = nil
flipper_left = nil

-- Flipper id values
flipper_right_id = 1
flipper_left_id = 0

-- A variable to determine if the flipper is fully flicked

-- Whether the flipper is in a flicked state
flipper_right_up = false
flipper_left_up = false

-- The acceleration due to gravity
g = 200

-- An array for the bumpers
bumpers = { }

-- An array for the dots
dots = { }

-- A variable for the score
score = 0
bumper_score = 150
dot_score = 50
all_dots_score = 500

level = 1
bumper_rgb = { { 0, 191/255, 1 }, { 124/255, 252/255, 0 }, { 1, 1, 0 }, { 1, 20/255, 147/255 } }
dot_rgb = { { 1, 1, 0 }, { 1, 0, 0 } }
all_dots_on_timer = 0

plunger = nil
plunger_force = 0
max_plunger_force = 4000
plunger_z = 0
plunger_z_max = 15
plunger_z_max_timer = 20


----- Helper functions
-- Sets up the table
function init_table()
   local wall_r = 139/255
   local wall_g = 136/255
   local wall_b = 120/255
   local brush = E.create_brush()
   E.set_brush_color(brush, wall_r, wall_g, wall_b, 1)

   --The west wall
   wall_west = E.create_object("bin/box.obj")
   E.set_entity_position(wall_west, -table_w/2 - wall_th/2, wall_h/2, 0.0)
   E.set_entity_geom_type(wall_west, E.geom_type_box, wall_th, wall_h*10, table_l+2*wall_th)
   E.parent_entity(wall_west, pivot)
   E.set_mesh(wall_west, 0, brush)
   local minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_west)
   local current_h = maxy-miny
   local current_w = maxz-minz
   local current_th = maxx-minx
   E.set_entity_scale(wall_west, wall_th/current_th, wall_h/current_h, (table_l+2*wall_th)/current_w)
   
   -- The east wall
   wall_east = E.create_object("bin/box.obj")
   E.set_entity_position(wall_east, table_w/2 + wall_th/2, wall_h/2, 0.0)
   E.set_entity_geom_type(wall_east, E.geom_type_box, wall_th, wall_h*10, table_l+2*wall_th)
   E.parent_entity(wall_east, pivot)
   E.set_mesh(wall_east, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_east)
   current_h = maxy-miny
   current_w = maxz-minz
   current_th = maxx-minx
   E.set_entity_scale(wall_east, wall_th/current_th, wall_h/current_h, (table_l+2*wall_th)/current_w)

   -- The north wall
   wall_north = E.create_object("bin/box.obj")
   E.set_entity_position(wall_north, 0.0, wall_h/2, -table_l/2-wall_th/2)
   E.set_entity_geom_type(wall_north, E.geom_type_box, table_w, wall_h*10, wall_th)
   E.parent_entity(wall_north, pivot)
   E.set_mesh(wall_north, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_north)
   local current_l = maxx-minx
   current_h = maxy-miny
   current_th = maxz-minz
   E.set_entity_scale(wall_north, table_w/current_l, wall_h/current_h, wall_th/current_th)

   local theta = 45
   local cos_theta = math.cos(theta*math.pi/180)
   local sin_theta = math.sin(theta*math.pi/180)

   -- The south west wall
   wall_sw = E.create_object("bin/box.obj")
   E.set_entity_position(wall_sw, -table_w/3-cos_theta*wall_th/2, wall_h/2, table_l/2-(sin_theta*wall_th/2 + cos_theta*cos_theta*table_w/3))
   E.set_entity_geom_type(wall_sw, E.geom_type_box, (table_w/3)/cos_theta, wall_h*10, wall_th)
   E.parent_entity(wall_sw, pivot)
   E.set_mesh(wall_sw, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_sw)
   current_l = maxx-minx
   current_h = maxy-miny
   current_th = maxz-minz
   E.set_entity_scale(wall_sw, ((table_w/3)/cos_theta)/current_l, wall_h/current_h, wall_th/current_th)
   E.turn_entity(wall_sw, 0, -35, 0)
   E.set_entity_geom_attr(wall_sw, E.geom_attr_callback, 3)

   --[[ The south east wall
   wall_se = E.create_object("bin/box.obj")
   E.set_entity_position(wall_se, table_w/3+cos_theta*wall_th/2, wall_h/2, table_l/2-(sin_theta*wall_th/2 + cos_theta*cos_theta*table_w/3))
   E.set_entity_geom_type(wall_se, E.geom_type_box, (table_w/3)/cos_theta, wall_h*10, wall_th)
   E.parent_entity(wall_se, pivot)
   E.set_mesh(wall_sw, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_se)
   current_l = maxx-minx
   current_h = maxy-miny
   current_th = maxz-minz
   E.set_entity_scale(wall_se, ((table_w/3)/cos_theta)/current_l, wall_h/current_h, wall_th/current_th)
   E.turn_entity(wall_se, 0, 35, 0)]]

   --the dividing wall between the entry ramp and the playing area
   local wall_div = E.create_object("bin/box.obj")
   E.set_entity_position(wall_div, 35 + wall_th/2, wall_h/2, 20/2)
   E.set_entity_geom_type(wall_div, E.geom_type_box, wall_th, wall_h*10, table_l-20)
   E.parent_entity(wall_div, pivot)
   E.set_mesh(wall_div, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_div)
   current_h = maxy-miny
   current_w = maxz-minz
   current_th = maxx-minx
   E.set_entity_scale(wall_div, wall_th/current_th, wall_h/current_h, (table_l-20)/current_w)
   --E.set_entity_flags(wall_div, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(wall_div, E.entity_flag_wireframe, true)

   --a wall at the bottom of the entry ramp
   local wall_base = E.create_object("bin/box.obj")
   E.set_entity_position(wall_base, 35 + wall_th + 5/2, wall_h/2, table_l/2-wall_th)
   E.set_entity_geom_type(wall_base, E.geom_type_box, 15, wall_h*10, wall_th*2)
   E.parent_entity(wall_base, pivot)
   E.set_mesh(wall_base, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_base)
   current_h = maxy-miny
   current_w = maxz-minz
   current_th = maxx-minx
   E.set_entity_scale(wall_base, 15/current_th, wall_h/current_h, wall_th*2/current_w)
    E.set_entity_geom_attr(object, E.geom_attr_bounce, 0)
   

   --a curve at the end of the ramp
   local curve = E.create_object("bin/curve.obj")
   E.set_entity_position(curve, 45.5, wall_h/2, -95.5)
   --E.set_entity_geom_type(curve, E.geom_type_box, 10, wall_h*10, 10)
   E.parent_entity(curve, pivot)
   E.set_mesh(curve, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(curve)
   current_h = maxy-miny
   current_w = maxz-minz
   current_th = maxx-minx
   E.set_entity_scale(curve, 15/current_th, wall_h/current_h, 15/current_w)
   --E.set_entity_flags(curve, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(curve, E.entity_flag_wireframe, true)

   --some geoms for the curve
   local geom_curve_1 = E.create_object("bin/box.obj")
   E.set_entity_position(geom_curve_1, 45.5+1.5, wall_h/2, -95.5-1.5)
   E.set_entity_geom_type(geom_curve_1, E.geom_type_box, 10, wall_h*10, 5)
   E.turn_entity(geom_curve_1, 0, -45, 0)
   E.parent_entity(geom_curve_1, pivot)
   --E.set_entity_flags(geom_curve_1, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(geom_curve_1, E.entity_flag_wireframe, true)
   E.set_entity_flags(geom_curve_1, E.entity_flag_hidden, true)
   local geom_curve_2 = E.create_object("bin/box.obj")
   E.set_entity_position(geom_curve_2, 45.5-5, wall_h/2, -95.5-5)
   E.set_entity_geom_type(geom_curve_2, E.geom_type_box, 10, wall_h*10, 5)
   E.turn_entity(geom_curve_2, 0, -22.5, 0)
   E.parent_entity(geom_curve_2, pivot)
   --E.set_entity_flags(geom_curve_2, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(geom_curve_2, E.entity_flag_wireframe, true)
   E.set_entity_flags(geom_curve_2, E.entity_flag_hidden, true)
   local geom_curve_3 = E.create_object("bin/box.obj")
   E.set_entity_position(geom_curve_3, 45.5+5.9, wall_h/2, -95.5+5)
   E.set_entity_geom_type(geom_curve_3, E.geom_type_box, 10, wall_h*10, 5)
   E.turn_entity(geom_curve_3, 0, -77.5, 0)
   E.parent_entity(geom_curve_3, pivot)
   --E.set_entity_flags(geom_curve_3, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(geom_curve_3, E.entity_flag_wireframe, true)
   E.set_entity_flags(geom_curve_3, E.entity_flag_hidden, true)

   -- A plunger
   plunger = E.create_object("bin/plunger.obj")
   E.set_entity_position(plunger, 35 + wall_th + 5/2, wall_h/2, table_l/2-wall_th)
   --E.set_entity_position(plunger, 10, 10, 10)
   --E.set_entity_geom_type(plunger, E.geom_type_box, 15, wall_h*10, wall_th*2)
   E.parent_entity(plunger, pivot)
   local plunger_brush = E.create_brush()
   E.set_brush_color(plunger_brush, 1, 1, 1, 1)
   E.set_mesh(plunger, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(plunger)
   current_h = maxy-miny
   current_w = maxz-minz
   current_th = maxx-minx
   --E.set_entity_geom_attr(plunger, E.geom_attr_mass, ball_m*2)
   --E.add_entity_force(plunger, 0, 0, -1000)
   --E.set_entity_scale(plunger, 15/current_th, wall_h/current_h, wall_th*2/current_w)

   --[[finish line
   finish_line = E.create_object()
   E.parent_entity(finish_line, pivot)
   E.set_entity_geom_type(finish_line, E.geom_type_box, table_w, wall_th, wall_th)
   E.set_entity_position(finish_line, 0, 0, table_l/2+wall_th/2)
   --Allow ball to pass through the finish line
   E.set_entity_geom_attr(finish_line, E.geom_attr_soft_cfm, 1.0)
   E.set_entity_geom_attr(finish_line, E.geom_attr_bounce, wall_bounce)
   E.set_entity_flags(finish_line, E.entity_flag_visible_geom, true)
   ]]


   add_circle_bumper(0,0)
   add_circle_bumper(8,-8)
   add_circle_bumper(-8,-8)

   add_dot(-20, -20)
   add_dot(-20, 20)
   add_dot(20, 20)
   add_dot(20, -20)
   --add_dot(-10, -10)
   --add_dot(-10, 10)
   --add_dot(10, 10)
   --add_dot(10, -10)


   --[[
   for i = -40, 40, 20 do
      for j = -70, 40, 20 do
	 add_circle_bumper(i, 0, j)
      end
   end
   for i = -30, 30, 20 do
      for j = -80, 50, 20 do
	 add_circle_bumper(i, 0, j)
      end
   end
   ]]

   E.set_entity_geom_attr(wall_west, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(wall_east, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(wall_north, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(wall_sw, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(wall_se, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(wall_west, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(wall_east, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(wall_north, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(wall_sw, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(wall_se, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(wall_west, E.geom_attr_friction, wall_friction)
   E.set_entity_geom_attr(wall_east, E.geom_attr_friction, wall_friction)
   E.set_entity_geom_attr(wall_north, E.geom_attr_friction, wall_friction)
   E.set_entity_geom_attr(wall_sw, E.geom_attr_friction, wall_friction)
   E.set_entity_geom_attr(wall_se, E.geom_attr_friction, wall_friction)
   E.set_entity_geom_attr(wall_sw, E.geom_attr_category, category_world)
   E.set_entity_geom_attr(wall_sw, E.geom_attr_collider, category_ball)
   E.set_entity_geom_attr(wall_se, E.geom_attr_category, category_world)
   E.set_entity_geom_attr(wall_se, E.geom_attr_collider, category_ball)
   --E.set_entity_flags(wall_west, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(wall_east, E.entity_flag_visible_geom, true)
   --E.set_entity_flags(wall_north, E.entity_flag_visible_geom, true)

   -- A plane just above the table so the balls cannot bounce
   --local ceiling = E.create_object("bin/checker.obj")
   --E.set_entity_geom_type(ceiling, E.geom_type_plane, 0, -1, 0, -ball_r*2+0.5)
   --E.set_entity_geom_attr(ceiling, E.geom_attr_category, category_world)
   --E.set_entity_geom_attr(ceiling, E.geom_attr_collider, category_all)
   --E.set_entity_geom_attr(ceiling, E.geom_attr_friction, 0)
   --E.parent_entity(ceiling, pivot)
   --E.set_entity_flags(ceiling, E.entity_flag_hidden, true)

   return true
end

function add_circle_bumper(x, z)
   -- A circular bumper twice as wide as the ball
   local bumper_circle = E.create_object("bin/circle_bumper.obj")
   E.parent_entity(bumper_circle, pivot)
   E.turn_entity(bumper_circle, -90, 0, 0)
   --E.set_entity_scale(bumper_circle, 2, 2, 2)
   local minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(bumper_circle)
   local current_d = maxx-minx
   local current_h = maxy-miny
   E.set_entity_position(bumper_circle, x+current_d/6.4, 0, z+current_d/18)
   local brush1 = E.create_brush()
   E.set_brush_color(brush1, 70/255, 130/255, 180/255, 1)
   local brush2 = E.create_brush()
   E.set_brush_color(brush2, bumper_rgb[level][1], bumper_rgb[level][2], bumper_rgb[level][3], 1)
   E.set_mesh(bumper_circle, 0, brush1)
   E.set_mesh(bumper_circle, 1, brush2)
   E.set_mesh(bumper_circle, 2, brush1)
   E.set_mesh(bumper_circle, 3, brush2)
   E.set_entity_scale(bumper_circle, 2*ball_r*2/current_d, 2*ball_r*2/current_h, 2*ball_r*2/current_d)
   --E.set_entity_flags(bumper_circle, E.entity_flag_wireframe, true)
   --E.set_entity_geom_attr(bumper_circle, E.geom_attr_callback, 0)

   local bumper_circle_geom = E.create_object("bin/circle_bumper.obj")
   E.parent_entity(bumper_circle_geom, pivot)
   --E.set_entity_scale(bumper_circle_geom, 2, 2, 2)
   E.set_entity_geom_type(bumper_circle_geom, E.geom_type_capsule, ball_r*1.55, ball_r*2)
   E.turn_entity(bumper_circle_geom, -90, 0, 0)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(bumper_circle_geom)
   local current_d = maxx-minx
   local current_h = maxy-miny
   E.set_entity_position(bumper_circle_geom, x, ball_r, z)
   E.set_entity_scale(bumper_circle_geom, 2*ball_r*2/current_d, 2*ball_r*2/current_h, 2*ball_r*2/current_d)
   E.set_entity_flags(bumper_circle_geom, E.entity_flag_hidden, true)
   --E.set_entity_geom_attr(bumper_circle_geom, E.geom_attr_callback, 3)

   --The bumpers array holds an array for each bumper, each having:
   --the geom [1],
   --the bumper [2],
   --a value to determine if the bumper should be lit [3],
   --the x coordinate [4]
   --the y coordinate [5]
   --the z coordinate [6]
   --and a value to determine if the bumper should be returned to its original position [7]
   bumpers[#bumpers+1] = { bumper_circle_geom, bumper_circle, 0, x+current_d/6.4, 0, z+current_d/18, 0 }
	--print("bump", bumper_circle)
	--print("bumpgeom", bumper_circle_geom)
end

function add_dot(x, z)
   local dot = E.create_object("bin/dot2.obj")
   E.parent_entity(dot, pivot)
   local brush1 = E.create_brush()
   E.set_brush_color(brush1, 70/255, 130/255, 180/255, 1)
   local brush2 = E.create_brush()
   E.set_brush_color(brush2, dot_rgb[1][1], dot_rgb[1][2], dot_rgb[1][3], 1)
   E.set_mesh(dot, 0, brush1)
   E.set_mesh(dot, 1, brush2)
   --E.turn_entity(dot, 90, 0, 0)
   E.set_entity_geom_type(dot, E.geom_type_ray, 0, 0, 0, 0, 20, 0)
   --E.turn_entity(dot, -90, 0, 0)
   --E.set_entity_flags(dot, E.entity_flag_visible_geom, true)
   --E.set_entity_geom_attr(dot, E.geom_attr_collider, 0)
   E.set_entity_geom_attr(dot, E.geom_attr_callback, 4)
   E.set_entity_position(dot, x, 0.1, z)
   
   --The dotss array holds an array for each dot, each having:
   --the dot [1]
   --and a boolean value to determine if the dot is on [2]
   dots[#dots+1] = { dot, false }
   --E.set_entity_scale(dot, 5, 5, 5)
   --E.turn_entity(dot, 180, 0, 0)
end


--only for the left flipper currently
function add_flippers()

-- Add a flipper for testing
   local flipper = E.create_object("bin/flipper2.obj")

   E.parent_entity(flipper, pivot)

   E.set_entity_body_type(flipper, true)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(flipper)
   E.set_entity_geom_type(flipper, E.geom_type_box, (maxx-minx)*(ball_r*2)/(maxy-miny), ball_r*10*2, (maxz-minz)*(ball_r*2*2)/(maxy-miny))


   --E.set_entity_scale(flipper, (ball_r*2)/(maxy-miny), (ball_r*2)/(maxy-miny), (ball_r*2)/(maxy-miny))

   --minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(flipper)
   --print(minx, miny, minz, maxx, maxy, maxz)
   --print(maxx-minx, maxy-miny, maxz-minz)
   --local x, y, z = E.get_entity_position(flipper)
   --print(x, y, z)
   local flipper_brush = E.create_brush()
   E.set_brush_color(flipper_brush, 255/255, 255/255, 255/255, 1)
   E.set_mesh(flipper, 0, flipper_brush)

   E.set_entity_geom_attr(flipper, E.geom_attr_category, category_flipper)
   E.set_entity_geom_attr(flipper, E.geom_attr_collider, category_ball)

   E.set_entity_flags(flipper, E.entity_flag_wireframe, true)
   E.set_entity_geom_attr(flipper, E.geom_attr_mass, 1)
   E.set_entity_geom_attr(flipper, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(flipper, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(flipper, E.geom_attr_friction, wall_friction)

   E.set_entity_position(flipper, -9.6 - 2, 1.5*ball_r, 93.9)
   E.turn_entity(flipper, 0, 60, 0)
   --E.set_entity_rotation(flipper, 0, 20, 0)

   flipper_left = flipper
   --E.set_entity_scale(flipper, 3, 3, 3)
   E.set_entity_flags(flipper, E.entity_flag_visible_geom, true)


-- Add a flipper for testing
   local flipper2 = E.create_object("bin/flipper2.obj")

   E.parent_entity(flipper2, pivot)

   E.set_entity_body_type(flipper2, true)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(flipper2)
   E.set_entity_geom_type(flipper2, E.geom_type_box, (maxx-minx)*(ball_r*2)/(maxy-miny), ball_r*10*2, (maxz-minz)*(ball_r*2* 2)/(maxy-miny))


   --E.set_entity_scale(flipper2, (ball_r*2)/(maxy-miny), (ball_r*2)/(maxy-miny), (ball_r*2)/(maxy-miny))

   --minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(flipper)
   --print(minx, miny, minz, maxx, maxy, maxz)
   --print(maxx-minx, maxy-miny, maxz-minz)
   --local x, y, z = E.get_entity_position(flipper)
   --print(x, y, z)
   --local flipper_brush = E.create_brush()
   --E.set_brush_color(flipper_brush, 255/255, 255/255, 255/255, 1)
   E.set_mesh(flipper2, 0, flipper_brush)

   E.set_entity_geom_attr(flipper2, E.geom_attr_category, category_flipper)
   E.set_entity_geom_attr(flipper2, E.geom_attr_collider, category_ball)

   E.set_entity_flags(flipper2, E.entity_flag_wireframe, true)
   E.set_entity_geom_attr(flipper2, E.geom_attr_mass, 1)
   E.set_entity_geom_attr(flipper2, E.geom_attr_callback, 0)
   E.set_entity_geom_attr(flipper2, E.geom_attr_bounce, wall_bounce)
   E.set_entity_geom_attr(flipper2, E.geom_attr_friction, wall_friction)

   E.set_entity_position(flipper2, 9.6 + 2, ball_r*1.5, 93.9)
   E.turn_entity(flipper2, 0, -60, 0)
   --E.set_entity_rotation(flipper, 0, 20, 0)

   flipper_right = flipper2
   --E.set_entity_scale(flipper, 3, 3, 3)
   E.set_entity_flags(flipper2, E.entity_flag_visible_geom, true)
end

-- Add a ball
function add_ball()
    local object = E.create_object("bin/ball.obj")
    local brush = E.create_brush()
    E.set_brush_color(brush, 1, 1, 1, 1)
    E.set_mesh(object, 0, brush)
    E.set_mesh(object, 1, brush)
    E.set_brush_image(E.get_mesh(object, 2), envmap, 1)
    E.set_brush_flags(E.get_mesh(object, 2), E.brush_flag_env_map_1, true)

    E.set_entity_position(object, ball_i_x, ball_i_y, ball_i_z)

    E.set_entity_rotation(object, math.random(-180, 180),
                                  math.random(-180, 180),
                                  math.random(-180, 180))
    --table.insert(objects, object)

-- Make this an object which is under control of ode
    E.set_entity_body_type(object, true)
    
    local minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(object)
    local current_d = maxx-minx
    local current_r = current_d/2
    E.set_entity_scale(object, ball_r/current_r, ball_r/current_r, ball_r/current_r)

-- Make a sphere type with radius ball_r and mass ball_m
    E.set_entity_geom_type(object, E.geom_type_sphere, 1)
    E.set_entity_geom_attr(object, E.geom_attr_mass, ball_m)
    E.set_entity_geom_attr(object, E.geom_attr_bounce, ball_bounce)
    E.set_entity_geom_attr(object, E.geom_attr_friction, ball_friction)
    E.set_entity_geom_attr(object, E.geom_attr_soft_erp, ball_erp)
    E.set_entity_geom_attr(object, E.geom_attr_soft_cfm, ball_cfm)
    E.set_entity_body_attr(object, E.body_attr_gravity, false)
-- Set this up as a "world type" item
    E.set_entity_geom_attr(object, E.geom_attr_category, category_ball)
-- Interacts with all items
    E.set_entity_geom_attr(object, E.geom_attr_collider, category_all)

    E.set_entity_geom_attr(object, E.geom_attr_callback, 3)
    --E.set_entity_flags(object, E.entity_flag_visible_body, false)
    -- E.set_entity_flags(object, E.entity_flag_visible_geom, true)
    
    --local i = num
    --if i == 0 then i = 16 end
    --local x, y, z = E.get_entity_position(object) --balls[i][2-4]
    --local xx, xy, xz = E.get_entity_x_vector(object) --balls[i][5-7]
    --local yx, yy, yz = E.get_entity_y_vector(object) --balls[i][8-10]
    --local zx, zy, zz = E.get_entity_z_vector(object) --balls[i][11-13]
    --balls[i] = { object, x, y, z, xx, xy, xz, yx, yy, yz, zx, zy, zz }
    
    E.parent_entity(object, pivot)

    ball = object

    --return ball
end

function reset()
   ball_i_x = math.random(10*(-table_w/2+ball_r), 10*(table_w/2-ball_r))/10
   ball_i_z = math.random(10*(-table_l/2+ball_r), 0)/10
   E.delete_entity(ball)
   ball = nil
   add_ball()
end

-- Flicks the flipper up if flick is true, otherwise it "unflicks" it
function flick_flipper(num, flick)
   if flick then
      if num == flipper_right_id then
	 if not flipper_right_up then
	    -- flick the right flipper
	    flipper_right_up = true
	 end
      elseif num == flipper_left_id then
	 if not flipper_left_up then
	    --apply a torque to the flipper
	    flipper_left_up = true
	    --E.set_entity_rotation(flipper_left, 0, 10, 0)
	    --print(flipper_left == nil)
	 end
      end
   else
      if num == flipper_right_id then
	 if flipper_right_up then
	    -- unflick the right flipper
	    flipper_right_up = false
	 end
      elseif num == flipper_left_id then
	 if flipper_left_up then
	    -- unflick the left flipper
	    flipper_left_up = false
	 end
      end
   end
end

function apply_gravity()
   local cos_angle = 0.9925461516 --the angle of the table is 7 degrees
   local sin_angle = 0.1218693434
   E.add_entity_force(ball, 0, -g*cos_angle, g*sin_angle)
   --local cur_x, cur_y, cur_z = E.get_entity_position(ball)
   --print(cur_x, cur_y, cur_z)
   return true
end

function cameraChange()
   if cam then
      camera_x = 0
      camera_y = 300
      camera_z = 0
      camera_turn_x = -45  -- -90 from original
      E.set_entity_position(camera, camera_x, camera_y, camera_z)
      E.turn_entity(camera, camera_turn_x,0,0)
   else
      camera_x = 0
      camera_y = 170
      camera_z = 200
      camera_turn_x = 45 -- -45 from original
      E.set_entity_position(camera, camera_x, camera_y, camera_z)
      E.turn_entity(camera, camera_turn_x,0,0)
   end
   cam = not cam
end

---- Event functions
-- timer (idle function)
function do_timer(dt)
   toReturn = false
   for i,v in ipairs(bumpers) do
      if v[3] >= 1 then
	 if v[7] >= 1 then
	    v[7] = v[7] - 1
	    if v[7] == 0 then
	       local x, y, z = E.get_entity_position(v[2])
	       E.set_entity_position(v[2], v[4], v[5], v[6])
	       toReturn = true
	    end
	 end
	 v[3] = v[3] - 1
	 if v[3] == 0 then
	    local brush = E.create_brush()
	    E.set_brush_color(brush, bumper_rgb[level][1], bumper_rgb[level][2], bumper_rgb[level][3], 1)
	    E.set_mesh(v[2], 1, brush)
	    E.set_mesh(v[2], 3, brush)
	    toReturn = true
	 end
      end
   end
   
   if all_dots_on_timer > 0 then
      all_dots_on_timer = all_dots_on_timer - 1
      if all_dots_on_timer == 0 then
	 score = score + all_dots_score
	 if level < 4 then
	    level = level + 1
	    for i,v in ipairs(bumpers) do
	       local brush = E.create_brush()
	       E.set_brush_color(brush, bumper_rgb[level][1], bumper_rgb[level][2], bumper_rgb[level][3], 1)
	       E.set_mesh(v[2], 1, brush)
	       E.set_mesh(v[2], 3, brush)
	    end
	 end
	 for i,v in ipairs(dots) do
	    local brush = E.create_brush()
	    E.set_brush_color(brush, dot_rgb[1][1], dot_rgb[1][2], dot_rgb[1][3], 1)
	    E.set_mesh(v[1], 1, brush)
	    v[2] = false
	    
	 end
	 toReturn = true
      else
	 for i,v in ipairs(dots) do
	    local value = all_dots_on_timer/10
	    local brush_num = 2 - ( ( (value - (value % 1) ) % 2))
	    local brush = E.create_brush()
	    E.set_brush_color(brush, dot_rgb[brush_num][1], dot_rgb[brush_num][2], dot_rgb[brush_num][3], 1)
	    E.set_mesh(v[1], 1, brush)
	 end
      end
   end
   if plunger_force > 0 then
      if plunger_force < max_plunger_force then
	 plunger_force = plunger_force + 50
      end
   end
   if plunger_z > 0 then
      if plunger_z < plunger_z_max then
	 if plunger_z_max_timer > 0 then
	    local x, y, z = E.get_entity_position(plunger)
	    E.set_entity_position(plunger, x, y, z-1)
	    plunger_z = plunger_z + 1
	 elseif plunger_z_max_timer == 0 then
	    local x, y, z = E.get_entity_position(plunger)
	    E.set_entity_position(plunger, x, y, z+1)
	    plunger_z = plunger_z - 1
	    if plunger_z == 0 then
	       plunger_z_max_timer = 20
	    end
	 end
      elseif plunger_z == plunger_z_max then
	 plunger_z_max_timer = plunger_z_max_timer - 1
	 if plunger_z_max_timer == 0 then
	    plunger_z = plunger_z - 1
	 end
      end
   end
   if not (ball == nil) then
      apply_gravity()
      toReturn = true
   end
   return toReturn
end

function do_frame()
	if flipper_left_up then
    	    E.add_entity_torque(flipper_left, 0, 1500 * 2, 0)
	else
	    E.add_entity_torque(flipper_left, 0, -1500 * 2, 0)
	end
	if flipper_right_up then
	    E.add_entity_torque(flipper_right, 0, -1500 * 2, 0)
	else
	    E.add_entity_torque(flipper_right, 0, 1500 * 2, 0)
	end

end

-- keyboard
function do_keyboard(key, down)
   if key == E.key_right then
      flick_flipper(flipper_right_id, down)
      return true
   elseif key == E.key_left then
      flick_flipper(flipper_left_id, down)
      return true
   elseif key == E.key_r and not down then --reset the pinball
      reset()
      return true
   elseif key == E.key_space then
      if down then --increase force of plunger
	 plunger_force = 1000
	 return false
      else --release plunger
	 local x, y, z = E.get_entity_position(ball)
	 if x > 41.5 and x < 49.5 and z > 86 and z < 90 then
	    E.add_entity_force(ball, 0, 0, -plunger_force)
	    plunger_z = 1
	 end
	 plunger_force = 0
	 return true
      end
   elseif key == E.key_c and not down then --change the camera view
      cameraChange()
      return true
   --[[elseif key == E.key_x then
      light_x = light_x + 5
      E.set_entity_position(light, light_x, light_y, light_z)
      return true
   elseif key == E.key_y then
      light_y = light_y + 5
      E.set_entity_position(light, light_x, light_y, light_z)
      return true
   elseif key == E.key_z then
      light_z = light_z + 5
      E.set_entity_position(light, light_x, light_y, light_z)
      return true
   elseif key == E.key_s then
      light_x = light_x - 5
      E.set_entity_position(light, light_x, light_y, light_z)
      return true
   elseif key == E.key_h then
      light_y = light_y - 5
      E.set_entity_position(light, light_x, light_y, light_z)
      return true
   elseif key == E.key_a then
      light_z = light_z - 5
      E.set_entity_position(light, light_x, light_y, light_z)
      return true]]
   end
   return false
end

-- mouse move
function do_point(dX, dY)
   mouse_X = mouse_X + dX
   mouse_Y = mouse_Y + dY
   return false
end

-- mouse click
function do_click(b, s)
   if b == 1 and not s then
      if not (ball == nil) then
	 force_x = 0--math.random(-30, 30)
	 force_y = 0
	 force_z = -1000
	 E.add_entity_force(ball, force_x, force_y, force_z)
	 return true
      end
   end
   return false
end

function do_contact(entityA, entityB, px, py, pz, nx, ny, nz, d)
	--Compare entities and their callback and category values
	--if ball == entityA then print(px, entityB, entityA) else print(px, entityA, entityB) 
	--print("aCat, bCall", E.get_entity_geom_attr(entityA, E.geom_attr_category),E.get_entity_geom_attr(entityB, E.geom_attr_callback))
	--print("bCat, aCall", E.get_entity_geom_attr(entityB, E.geom_attr_category),E.get_entity_geom_attr(entityA, E.geom_attr_callback))
	--end

	--Ball crossed finish line
	if finish_line == entityB or finish_line == entityA then
		reset()
	end
	--Ball hit angled bumper
   if wall_sw == entityB or wall_sw == entityA or wall_se == entityB or wall_se == entityA then
      local bumpsound = E.load_sound("bin/boing.ogg")
      --E.set_sound_emitter(bumpsound, ball)
      E.play_sound(bumpsound)
	E.free_sound(bumpsound)
   end
   if ball == entityA or ball == entityB then
      for i,v in ipairs(bumpers) do
		--Ball hit peg
	 if v[1] == entityB or v[1] == entityA then
	    local bumpsound = E.load_sound("bin/KirbyStyleLaser.ogg")
	    --E.set_sound_emitter(bumpsound, ball)
	    E.play_sound(bumpsound)
		E.free_sound(bumpsound)
	    E.add_entity_force(ball, 400*nx, 0, 400*nz)
	    local brush = E.create_brush()
	    E.set_brush_color(brush, 1, 0, 0, 1)
	    E.set_mesh(v[2], 1, brush)
	    E.set_mesh(v[2], 3, brush)
	    v[3] = 10
	    v[7] = 2
	    score = score + bumper_score
	    local x, y, z = E.get_entity_position(v[2])
	    E.set_entity_position(v[2], x - nx/2, y, z - nz/2)
	    return true
	 end
      end

      for i,v in ipairs(dots) do
		--Ball passed over dot
	 if v[1] == entityB or v[1] == entityA then
	    local brush = E.create_brush()
	    E.set_brush_color(brush, dot_rgb[2][1], dot_rgb[2][2], dot_rgb[2][3], 1)
	    E.set_mesh(v[1], 1, brush)
	    score = score + dot_score
	    v[2] = true
	    local all_dots_on = true
	    for i,v in ipairs(dots) do
	       if not v[2] then
		  all_dots_on = false
		  break
	       end
	    end
	    if all_dots_on then
	       all_dots_on_timer = 140
	    end
	    return true
	 end
      end
   end
   return false
end

-- main setup
function do_start()

    -- Set up background
    E.set_background(0.8, 0.8, 1.0, 0.2, 0.4, 1.0)

    -- Set up camera and position
    camera = E.create_camera(E.camera_type_perspective)
    E.set_entity_position(camera, camera_x, camera_y, camera_z)
    --E.turn_entity(camera, 0, camera_turn_y, 0)
    E.turn_entity(camera, camera_turn_x, 0, 0)
   
    -- Set up light
    light = E.create_light(E.light_type_positional)
    E.set_light_color(light, 1, 1, 1)
    -- Set up item to hang things off of for scaling
    pivot = E.create_pivot()

    -- Obtain objects for environment
    plane = E.create_object("bin/checker.obj")

    -- view of camera
    E.set_camera_range(camera, 1, 10000)

    -- relationships
    E.parent_entity(light, camera)
    E.parent_entity(pivot, light)
    E.parent_entity(plane, pivot)

    -- set up plane as plane with normal in y direction
    E.set_entity_geom_type(plane, E.geom_type_plane, 0, 1, 0, 0)
    -- interacts with all items - part of world
    E.set_entity_geom_attr(plane, E.geom_attr_category, category_world)
    E.set_entity_geom_attr(plane, E.geom_attr_collider, category_all)
    E.set_entity_geom_attr(plane, E.geom_attr_friction, table_friction)
    local brush = E.create_brush()
    local plane_r = 0.2--0.6
    local plane_g = 0.2--1
    local plane_b = 0.2--0.6
    E.set_brush_color(brush, plane_r, plane_g, plane_b, 1)
    E.set_mesh(plane, 0, brush)
    E.set_mesh(plane, 1, brush)
    local minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(plane)
    current_l = maxx-minx
    if current_l < 0 then current_l = -current_l end
    current_w = maxz-minz
    if current_w < 0 then current_w = -current_w end

    -- locate light
    E.set_entity_position(light, light_x, light_y, light_z)

    -- Scale items
    local scale_x = table_w/current_l
    local scale_z = table_l/current_w
    E.set_entity_scale(plane, scale_x, 1, scale_z)

    -- Tilt the table down
    --E.turn_entity(pivot, 0, 0, 10)

    add_flippers()
    E.set_entity_joint_type(flipper_left, plane, E.joint_type_hinge)
    E.set_entity_joint_attr(flipper_left, plane, E.joint_attr_axis_1, 0, 1, 0)
   local anchorx, anchorz
   anchorx = -9.6 - ((maxx-minx)/2)*math.sin(60*math.pi/180) - 2
   anchorz = 93.9 - ((maxz-minz)/2)*math.cos(60*math.pi/180)
   E.set_entity_joint_attr(flipper_left, plane, E.joint_attr_anchor, anchorx, ball_r*1.5, anchorz)
   E.set_entity_joint_attr(flipper_left, plane, E.joint_attr_lo_stop, -15)
   E.set_entity_joint_attr(flipper_left, plane, E.joint_attr_hi_stop, 120)

    E.set_entity_joint_type(flipper_right, plane, E.joint_type_hinge)
    E.set_entity_joint_attr(flipper_right, plane, E.joint_attr_axis_1, 0, 1, 0)
   local anchorx2, anchorz2
   anchorx2 = 9.6 + ((maxx-minx)/2)*math.sin(60*math.pi/180) + 2
   anchorz2 = 93.9 - ((maxz-minz)/2)*math.cos(60*math.pi/180)
   E.set_entity_joint_attr(flipper_right, plane, E.joint_attr_anchor, anchorx2, ball_r *1.5, anchorz2)
   E.set_entity_joint_attr(flipper_right, plane, E.joint_attr_hi_stop, 15)
   E.set_entity_joint_attr(flipper_right, plane, E.joint_attr_lo_stop, -120)

    -- tell user how to toggle console and exit
    E.print_console("Type F1 to toggle this console.\n")
    E.print_console("Type F2 to toggle full-screen.\n")
    E.print_console("Type escape to exit this program.\n")
    E.print_console("Type 'r' to reset the ball.\n")
    E.print_console("Type 'c' to change the camera view.\n")

    E.enable_timer(true)
	--E.set_sound_receiver(camera, 400)
   --E.set_entity_flags(camera, E.entity_flag_wireframe, true)
   E.set_typeface("bin/Adventure_Subtitles_Normal.ttf")

end

do_start()
init_table()
add_ball()


--print("plane",plane)
--print("n",wall_n)
--print("w",wall_w)
--print("sw",wall_sw)
--print("e",wall_e)
--print("se",wall_se)
--print("bot",finish_line)
--print("baLL",ball)

