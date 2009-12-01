-- GLOBAL CONSTANTS

-- catagories for items of ode - for identifing what things interact with other items
category_world = 4
category_all = category_world


-- Position of camera
camera_x = 0
camera_y = 170--15--170
camera_z = 200--200--200
camera_turn_x = -45---45---2---45
camera_turn_y = 0 --not used
camera_turn_z = 0 --not used

-- Scaling constant (distance units per cm)
scale = 1.43163923

-- Ball attributes
ball = nil
ball_r = 1.5
ball_m = .160
ball_bounce = 1
ball_friction = 0
ball_erp = .2
ball_cfm = 0.01

-- Table attributes
table_l = 139.7 * scale --27.5 in
table_w = 68.58 * scale --55 in
wall_h = ball_r * 2
wall_th = 10
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

-- Flippers
flipper_right = nil
flipper_left = nil

-- Flipper id values
flipper_right_id = 1
flipper_left_id = 0

-- A variable to determine if the flipper is fully flicked

-- Whether the flipper is in a flicked state
--flipper_right_up = false
--flipper_left_up = false

-- The acceleration due to gravity
g = 200

-- An array for the bumpers
bumpers = { }

-- A variable for the score
score = 0
bumper_score = 150



----- Helper functions
-- Sets up the table
function init_table()
   local wall_r = 139/255
   local wall_g = 136/255
   local wall_b = 120/255
   local brush = E.create_brush()
   E.set_brush_color(brush, wall_r, wall_g, wall_b, 1)

   --The west wall
   local wall_west = E.create_object("bin/box.obj")
   E.set_entity_position(wall_west, -table_w/2 - wall_th/2, wall_h/2, 0.0)
   E.set_entity_geom_type(wall_west, E.geom_type_box, wall_th, wall_h, table_l+2*wall_th)
   E.parent_entity(wall_west, pivot)
   E.set_mesh(wall_west, 0, brush)
   local minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_west)
   local current_h = maxy-miny
   local current_w = maxz-minz
   local current_th = maxx-minx
   E.set_entity_scale(wall_west, wall_th/current_th, wall_h/current_h, (table_l+2*wall_th)/current_w)
   
   -- The east wall
   local wall_east = E.create_object("bin/box.obj")
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
   local wall_north = E.create_object("bin/box.obj")
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
   local wall_sw = E.create_object("bin/box.obj")
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

   -- The south east wall
   local wall_se = E.create_object("bin/box.obj")
   E.set_entity_position(wall_se, table_w/3+cos_theta*wall_th/2, wall_h/2, table_l/2-(sin_theta*wall_th/2 + cos_theta*cos_theta*table_w/3))
   E.set_entity_geom_type(wall_se, E.geom_type_box, (table_w/3)/cos_theta, wall_h*10, wall_th)
   E.parent_entity(wall_se, pivot)
   E.set_mesh(wall_sw, 0, brush)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(wall_se)
   current_l = maxx-minx
   current_h = maxy-miny
   current_th = maxz-minz
   E.set_entity_scale(wall_se, ((table_w/3)/cos_theta)/current_l, wall_h/current_h, wall_th/current_th)
   E.turn_entity(wall_se, 0, 35, 0)
   


   -- Add a flipper for testing
   local flipper = E.create_object("bin/flipper2.obj")
   E.set_entity_position(flipper, -9, ball_r, 94)
   E.parent_entity(flipper, pivot)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(flipper)
   E.set_entity_scale(flipper, (ball_r*2)/(maxy-miny), (ball_r*2)/(maxy-miny), (ball_r*2)/(maxy-miny))
   E.set_entity_geom_type(flipper, E.geom_type_box, (maxx-minx)*(ball_r*2)/(maxy-miny), ball_r*10, (maxz-minz)*(ball_r*2)/(maxy-miny))
   --minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(flipper)
   --print(minx, miny, minz, maxx, maxy, maxz)
   --print(maxx-minx, maxy-miny, maxz-minz)
   local x, y, z = E.get_entity_position(flipper)
   --print(x, y, z)
   local flipper_brush = E.create_brush()
   E.set_brush_color(flipper_brush, 255/255, 255/255, 255/255, 1)
   E.set_mesh(flipper, 0, flipper_brush)
   --E.set_entity_body_type(flipper, true)
   --E.set_entity_geom_attr(flipper, E.geom_attr_category, category_world)
   --E.set_entity_geom_attr(flipper, E.geom_attr_collider, category_all)
   E.set_entity_joint_type(flipper, plane, E.joint_type_hinge)
   --E.set_entity_flags(flipper, E.entity_flag_wireframe, true)
   E.set_entity_joint_attr(flipper, plane, E.joint_attr_anchor, -10, 3, 84)
   E.set_entity_joint_attr(flipper, plane, E.joint_attr_axis_1, 0, 1, 0)
   E.set_entity_rotation(flipper, 0, 60, 0)
   --E.set_entity_position(flipper, 0, 3, -4)
   flipper_left = flipper
   --E.set_entity_scale(flipper, 3, 3, 3)
   --E.set_entity_flags(flipper, E.entity_flag_visible_geom, true)

   add_circle_bumper(0,0,0)
   add_circle_bumper(5,0,-5)
   add_circle_bumper(-5,0,-5)
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

function add_circle_bumper(x, y, z)
   -- A circular bumper twice as wide as the ball
   local bumper_circle = E.create_object("bin/circle_bumper.obj")
   E.parent_entity(bumper_circle, pivot)
   --E.set_entity_geom_type(bumper_circle, E.geom_type_capsule, 1, 1)
   E.turn_entity(bumper_circle, -90, 0, 0)
   --E.set_entity_scale(bumper_circle, 2, 2, 2)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(bumper_circle)
   local current_d = maxx-minx
   local current_h = maxy-miny
   E.set_entity_position(bumper_circle, x+current_d/6.4, y, z+current_d/18)
   brush1 = E.create_brush()
   E.set_brush_color(brush1, 70/255, 130/255, 180/255, 1)
   brush2 = E.create_brush()
   E.set_brush_color(brush2, 0, 191/255, 1.0, 1)
   E.set_mesh(bumper_circle, 0, brush1)
   E.set_mesh(bumper_circle, 1, brush2)
   E.set_mesh(bumper_circle, 2, brush1)
   E.set_mesh(bumper_circle, 3, brush2)
   E.set_entity_scale(bumper_circle, 2*ball_r*2/current_d, 2*ball_r*2/current_h, 2*ball_r*2/current_d)
   --E.set_entity_flags(bumper_circle, E.entity_flag_wireframe, true)
   E.set_entity_geom_attr(bumper_circle, E.geom_attr_callback, 0)

   local bumper_circle_geom = E.create_object("bin/circle_bumper.obj")
   E.parent_entity(bumper_circle_geom, pivot)
   --E.set_entity_scale(bumper_circle_geom, 2, 2, 2)
   E.set_entity_geom_type(bumper_circle_geom, E.geom_type_capsule, ball_r*1.55, ball_r*2)
   E.turn_entity(bumper_circle_geom, -90, 0, 0)
   minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(bumper_circle_geom)
   current_d = maxx-minx
   current_h = maxy-miny
   E.set_entity_position(bumper_circle_geom, x, y+ball_r, z)
   E.set_entity_scale(bumper_circle_geom, 2*ball_r*2/current_d, 2*ball_r*2/current_h, 2*ball_r*2/current_d)
   E.set_entity_flags(bumper_circle_geom, E.entity_flag_hidden, true)
   E.set_entity_geom_attr(bumper_circle_geom, E.geom_attr_callback, 3)

   --The bumpers array holds an array for each bumper, each having:
   --the geom [1],
   --the bumper [2],
   --a value to determine if the bumper should be lit [3],
   --the x coordinate [4]
   --the y coordinate [5]
   --the z coordinate [6]
   --and a value to determine if the bumper should be returned to its original position [7]
   bumpers[#bumpers+1] = { bumper_circle_geom, bumper_circle, 0, x+current_d/6.4, y, z+current_d/18, 0 }

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

-- Make this a object which is under control of ode
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
    E.set_entity_geom_attr(object, E.geom_attr_category, category_world)
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

    return object
end

-- Flicks the flipper up if flick is true, otherwise it "unflicks" it
function flick_flipper(num, flick)
   if flick then
      if num == flipper_right_id then
	 if not flipper_right_up then
	    -- flick the right flipper
	 end
      elseif num == flipper_left_id then
	 if not flipper_left_up then
	    --apply a torque to the flipper
	    --E.add_entity_torque(flipper_left, 0, 150, 0)
	    --print(flipper_left == nil)
	 end
      end
   else
      if num == flipper_right_id then
	 if flipper_right_up then
	    -- unflick the right flipper
	 end
      elseif num == flipper_left_id then
	 if flipper_left_up then
	    -- unflick the left flipper
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
	    E.set_brush_color(brush, 0, 191/255, 1.0, 1)
	    E.set_mesh(v[2], 1, brush)
	    E.set_mesh(v[2], 3, brush)
	    toReturn = true
	 end
      end
   end
   if not (ball == nil) then
      apply_gravity()
      toReturn = true
   end
   return toReturn
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
      ball_i_x = math.random(10*(-table_w/2+ball_r), 10*(table_w/2-ball_r))/10
      ball_i_z = math.random(10*(-table_l/2+ball_r), 0)/10
      E.delete_entity(ball)
      ball = nil
      add_ball()
      return true
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
	 force_x = math.random(-30, 30)
	 force_y = 0
	 force_z = -1000
	 E.add_entity_force(ball, force_x, force_y, force_z)
	 return true
      end
   end
   return false
end

function do_contact(entityA, entityB, px, py, pz, nx, ny, nz, d)
   local brush = E.create_brush()
   E.set_brush_color(brush, 1, 0, 0, 1)
   for i,v in ipairs(bumpers) do
      --through experiment, it appears that the bumper will only be entityB, though entityA is still checked
      if v[1] == entityB and ball == entityA then
	 E.add_entity_force(ball, 400*nx, 0, 400*nz)
	 E.set_mesh(v[2], 1, brush)
	 E.set_mesh(v[2], 3, brush)
	 v[3] = 10
	 v[7] = 2
	 score = score + bumper_score
	 local x, y, z = E.get_entity_position(v[2])
	 E.set_entity_position(v[2], x - nx/2, y, z - nz/2)
	 return true
      elseif v[1] == entityA and ball == entityB then
	 E.add_entity_force(ball, -400*nx, 0, -400*nz)
	 E.set_mesh(v[2], 1, brush)
	 E.set_mesh(v[2], 3, brush)
	 v[3] = 10
	 v[7] = 2
	 score = score + bumper_score
	 local x, y, z = E.get_entity_position(v[2])
	 E.set_entity_position(v[2], x + nx/2, y, z + nz/2)
	 return true
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
    E.set_brush_color(brush, 0.6, 1, 0.6, 1)
    E.set_mesh(plane, 0, brush)
    E.set_mesh(plane, 1, brush)
    local minx, miny, minz, maxx, maxy, maxz = E.get_entity_bound(plane)
    local current_l = maxx-minx
    if current_l < 0 then current_l = -current_l end
    local current_w = maxz-minz
    if current_w < 0 then current_w = -current_w end

    -- locate light
    E.set_entity_position(light, 0.0, 60.0, 40.0)

    -- Scale items
    --E.set_entity_scale(pivot, 1, 1, 1)
    E.set_entity_scale(plane, table_w/current_l, 1, table_l/current_w)

    -- Tilt the table down
    --E.turn_entity(pivot, 0, 0, 10)

    
    -- tell user how to toggle console and exit
    E.print_console("Type F1 to toggle this console.\n")
    E.print_console("Type F2 to toggle full-screen.\n")
    E.print_console("Type escape to exit this program.\n")

    E.enable_timer(true)
    
end

do_start()
init_table()
add_ball()

