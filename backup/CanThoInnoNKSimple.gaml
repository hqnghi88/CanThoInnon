/**
* Name: GeoTIFF file to Grid of Cells 
* Author:  Patrick Taillandier
* Description: Model which shows how to create a grid of cells by using a GeoTIFF File. 
* Tags:  load_file, tif, gis, grid
*/
model CanThoInno

global {
//definiton of the file to import
	file grid_data <- file('../includes/NKdemsimple.tif');
	file road_shp <- file("../includes/nkRoadsSimple.shp");
	file node_shp <- file("../includes/nkNodesSimple.shp");
	//		file road_shp <- file("../includes/ninhkieu.shp");
	//		file node_shp <- file("../includes/nodes.shp");
	file building_shp <- file("../includes/nkBuildingSimple.shp");
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(building_shp);
	file roof_texture <- file('../images/building_texture/roof_top.png');
	list
	textures <- [file('../images/building_texture/texture1.jpg'), file('../images/building_texture/texture2.jpg'), file('../images/building_texture/texture3.jpg'), file('../images/building_texture/texture4.jpg'), file('../images/building_texture/texture5.jpg'), file('../images/building_texture/texture6.jpg'), file('../images/building_texture/texture7.jpg'), file('../images/building_texture/texture8.jpg'), file('../images/building_texture/texture9.jpg'), file('../images/building_texture/texture10.jpg')];
	graph road_graph;
	bool draw_perception <- false;
	bool show_building_names <- false;
	float max_value;
	float min_value;
	bool recompute_path <- false;
	geometry road_geom;
	int nbvehicle <- 300;
	map<road, float> road_weights;
	list<traffic_light> moved_agents;
	point target;
	geometry zone <- circle(10);
	bool can_drop;

	init {
			ask cell {
				grid_value <- -grid_value ;//+ 33;
			} 
		
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
//		write max_value;
//		write min_value;
		ask cell {
		//			grid_value <- grid_value;
		//			float val <- (1 - (grid_value - min_value) / ((max_value - min_value) + 10));
		//			color <- hsb(35 / 360, val * val, 0.64);
			float val <- ( (grid_value - min_value) / (max_value - min_value));
			color <- hsb(222 / 360, val,0.3);
			//			color<-rgb(0,0,val*255);
		}

	//		create water {
	//			location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
	//		}
		create traffic_light from: node_shp {
//		//			is_traffic_signal <- true;
//			is_traffic_signal <- flip(0.1) ? true : false;
			color_fire <- flip(0.5) ? #red : #green;
			nbred <- 30 + rnd(70);
			nbgreen <- 15 + rnd(40);
		}
//		ask traffic_light {do die;}
		ask (length(traffic_light)*0.9) among traffic_light {do die;}

		//		tttt <- traffic_light where (each.is_traffic_signal);
		create road from: road_shp {
		}

		road_weights <- road as_map (each::each.shape.perimeter);
		road_geom <- union(road accumulate (each.shape));
		//		ask road{
		//			loop p over:shape.points{
		//				cell c<- cell at p;
		//				if(c!=nil){					
		//					p<- p add_z c.grid_value;
		//				}
		//			} 
		//		}
		road_graph <- as_edge_graph(list(road));
		create building from: building_shp {
			depth <- (10+(rnd(70)) / 150 * shape.width);
			texture <- textures[rnd(9)];
		}

		create vehicle number: nbvehicle {
			location <- any_location_in(road_geom);
			//			location <- any_location_in(any(road));
			//			target <- any_location_in(any(road));
		}

	}

	bool edit_traffic_light_mode <- false;
	//	user_command "Design Traffic Light" when:!edit_traffic_light_mode{ 
	//		edit_traffic_light_mode<-true;
	//	}
	//	user_command "Exit Traffic Light" when:edit_traffic_light_mode{ 
	//		edit_traffic_light_mode<-false;
	//	}
	//	action kill_traffic_light {
	//	//		if(!edit_traffic_light_mode) {return;}
	//		ask moved_agents {
	//			do die;
	//		}
	//
	//		moved_agents <- list<traffic_light>([]);
	//	}

	//	action duplicate_traffic_light {
	//	}
	user_command "Create a traffic light" {
	//		if(!edit_traffic_light_mode) {return;}
		geometry available_space <- (zone at_location target) - (union(moved_agents) + 10);
		create traffic_light number: 1 with: (location: any_location_in(available_space)) {
			//			is_traffic_signal <- flip(0.01)?true:false;
			color_fire <- flip(0.5) ? #red : #green;
			nbred <- 30 + rnd(70);
			nbgreen <- 15 + rnd(40);
		} }

		//	action click {
	//	//		if(!edit_traffic_light_mode) {return;}
	//		if (empty(moved_agents)) {
	//			list<traffic_light> selected_agents <- traffic_light inside (zone at_location #user_location);
	//			moved_agents <- selected_agents;
	//			ask selected_agents {
	//				difference <- #user_location - location;
	//				color <- #olive;
	//			}
	//
	//		} else if (can_drop) {
	//			ask moved_agents {
	//				color <- #burlywood;
	//			}
	//
	//			moved_agents <- list<traffic_light>([]);
	//		}
	//
	//	}
	action move {
		target <- #user_location;
		if (!edit_traffic_light_mode) {
			return;
		}

		can_drop <- true;
		list<traffic_light> other_agents <- (traffic_light inside (zone at_location #user_location)) - moved_agents;
		geometry occupied <- geometry(other_agents);
		ask moved_agents {
			location <- #user_location - difference;
			if (occupied intersects self) {
				color <- #red;
				can_drop <- false;
			} else {
				color <- #olive;
			}

		}

	} }

species traffic_light {
	
	point difference <- {0, 0};
	geometry shape <- square(1);
	int nbred;
	int nbgreen;
	rgb color_fire;
	int counter <- 0;
	user_command "take off" action: take_off;
	user_command "put down" action: put_down;

	action put_down {
		edit_traffic_light_mode <- false;
		ask moved_agents {
			color <- #burlywood;
		}

		moved_agents <- list<traffic_light>([]);
	}

	action take_off {
		edit_traffic_light_mode <- true;
		if (empty(moved_agents)) {
			list<traffic_light> selected_agents <- traffic_light inside (zone at_location #user_location);
			moved_agents <- selected_agents;
			ask selected_agents {
				difference <- #user_location - location;
				color <- #olive;
			}

		}

		list<traffic_light> other_agents <- (traffic_light inside (zone at_location #user_location)) - moved_agents;
		geometry occupied <- geometry(other_agents);
		ask moved_agents {
			location <- #user_location - difference;
			if (occupied intersects self) {
				color <- #red;
				can_drop <- false;
			} else {
				color <- #olive;
			}

		}

	}

	reflex change {
		if (color_fire = #red and counter > nbred) {
			counter <- 0;
			color_fire <- #green;
		}

		if (color_fire = #green and counter > nbgreen) {
			counter <- 0;
			color_fire <- #red;
		}

		counter <- counter + 1;
	}

	aspect default { 
			draw box(1, 1, 10) color: #black;
			draw sphere(5) at: {location.x, location.y, 12} color: color_fire; 

	}

}

species vehicle skills: [moving] {
	rgb color;
	string type;
	int nb_people;
	float wsize <- 5.0 + rnd(4);
	float hsize <- 2.0 + rnd(4);
	bool insane <- flip(0.0001) ? true : false;
	float speed <- (insane ? 70 + rnd(50) : 10 + rnd(60.0)) °km / °h;
	float csp <- speed;
	//	float ccsp <- csp;
	float perception_distance <- wsize * 4;
	geometry shape <- rectangle(wsize, hsize);
	geometry TL_area ;//<- (cone(heading - 10, heading + 10) intersection world.shape) intersection (circle(perception_distance));
	point target <- nil;
	rgb csd <- #green;
	bool waiting_traffic_light<-false;

	reflex move when: target != nil {
		TL_area <- (cone(heading - 15, heading + 15) intersection world.shape) intersection (circle(perception_distance));
		list<traffic_light> redlight <- (((traffic_light) at_distance perception_distance) where (each.color_fire = #red)) overlapping TL_area;
//		list v <- (vehicle at_distance (perception_distance)) overlapping TL_area;
		list<vehicle> v <- (vehicle at_distance (perception_distance)) where (!(each.TL_area overlaps TL_area) and (each overlaps TL_area));
		if (length(redlight) > 0) {
			waiting_traffic_light<-true;
//			csd <- #red;
			return;
		}
		if(!waiting_traffic_light and length(v where (each.waiting_traffic_light))>0){
			waiting_traffic_light<-true;
//			csd <- #red;
			return;			
		}
		waiting_traffic_light<-false;
		if (length(v) > 0) {
			csd <- #darkgreen;
			if (csp = speed) {
			//				if (csp = ccsp) {
			//					ccsp <- v min_of each.csp;
			//				}
				csp <- (v min_of each.csp);
			}

			//			if (ccsp > 6) {
			//				ccsp <- ccsp - 5;
			//			}

		} else {
		//			if(csp<sp){
			csd <- #green;
			csp <- speed;
			//			ccsp <- csp;
			//			}
		}

		do goto target: target on: road_graph recompute_path: recompute_path speed: csp move_weights: road_weights;
		if (target != nil and location distance_to target <= speed) {
		//		if (target = location){
			target <- nil;
		}
	}

	reflex choose_target when: target = nil {
		target <- any_location_in(road_geom);
		//		target <-any(building).location;
	}

	aspect default {
		draw shape color: csd border: #black depth: 1 rotate: heading;
						if (draw_perception and TL_area != nil) {
							draw TL_area color: csd empty:true depth: 0.5;
						}

	}

}

//species people skills: [moving] {
//	float size <- 1.0 + rnd(2);
//	float sp <- 20 + rnd(3.0);
//	geometry shape <- cube(size);
//	float range <- size * 2;
//	int repulsion_strength min: 1 <- 5;
//	point target;
//
//	reflex ss {
//		do goto target: target on: road_graph speed: sp;
//		if (target != nil and location distance_to target <= sp) {
//			target <- any_location_in(one_of(road));
//		}
//
//	}
//
//	aspect default {
//		draw shape color: #yellow;
//	}
//
//}
species road {

	int nbLanes<-1;
	float coeff_traffic <- 1.0 update: 1 + (float(length(vehicle at_distance 10.0)) / shape.perimeter * 20 / nbLanes);

	aspect default {
		draw shape + 5 empty: false color: #gray;
	}
	aspect traffic_jam {  
		if (coeff_traffic > 0.25) {
			draw shape + (coeff_traffic / 20.0) color: #red ;
		}
	} 		

}

//species water {
//	float wlevel <- -14.0;
//	int incr <- 1;
//	geometry shape <- box(world.shape.width, world.shape.height, 1);
//
//	reflex innon {
//		wlevel <- wlevel + incr * 0.05;
//		if (wlevel > -9) {
//			incr <- -1;
//		}
//
//		if (wlevel < -14.0) {
//			incr <- 1;
//		}
//
//		location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
//	}
//
//	aspect default {
//		draw shape color: #blue at: location;
//	}
//
//}
species building {
	float depth;
	string osm_name;
	file texture;

		reflex gravity {
			cell c <- first(cell overlapping self);
			if (c != nil) {
				c.grid_value <- c.grid_value - (shape.perimeter / 100);
			}
	
		}
	
	aspect default {
		draw shape depth: depth texture: [roof_texture.path, texture.path] color: rnd_color(255);
		if (show_building_names and osm_name index_of "osm_agent" != 0) {
		//			write osm_name;
			draw osm_name size: 0.010 color: #yellow at: {location.x, location.y, (depth + 1)} perspective: false;
		}

	}

}

grid cell file: grid_data {
}
experiment show_example type: gui {
	parameter "Show Building Name" var: show_building_names;
	font regular <- font("Helvetica", 14, #bold);
	output {
//		display traffic_jam_display {
//			species road;
//			species road aspect: traffic_jam ;
//		}
		display test
//			camera_pos: {356.5227,1917.5553,285.3626} camera_look_pos: {750.7957,988.7062,-62.0666} camera_up_vector: {0.1272,0.2997,0.9455}
		type: opengl 
//		background:#lightgray
		{
		//			species water;
		//						grid cell refresh: false;
			grid cell elevation: grid_value triangulation: true refresh: true position: {0, 0, -0.007} transparency: 0.0;
			species traffic_light;
			species road refresh: false; // position: {0, 0, 0.002};
			species building refresh: false;
			species vehicle; //position: {0, 0, 0.002};
			event mouse_move action: move;
			

		}
				
//						display FirstPerson type: opengl camera_interaction: false camera_pos: {int(first(vehicle).location.x), int(first(vehicle).location.y), 5.0} camera_look_pos:
//						{cos(first(vehicle).heading) * first(vehicle).speed + int(first(vehicle).location.x), sin(first(vehicle).heading) * first(vehicle).speed + int(first(vehicle).location.y), 5.0}
//						camera_up_vector: {0.0, 0.0, -1.0} {
//						//			grid cell elevation: grid_value triangulation: true refresh: false;
//							grid cell refresh: false;
//							species road refresh: false;
//							species building refresh: false;
//							species vehicle;
//						}
		
	}

}
