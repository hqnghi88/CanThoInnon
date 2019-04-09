model CanThoInno
import "../modules/GlobalVariable.gaml"
import "../modules/Moveable.gaml"
import "../modules/TrafficLight.gaml"
import "../modules/Vehicle.gaml"
import "../modules/Road.gaml"
import "../modules/Building.gaml"
import "../modules/Water.gaml"
import "../modules/PollutantGrid.gaml"
import "../modules/DEMCell.gaml"
global {
//definiton of the file to import
	
	init {
		ask DEMcell {
			subsidence <- subsidence + grid_value;
			color <- hsb(210 / 360, subsidence / 10 > 1 ? 1 : (subsidence / 10 < 0 ? 0 : subsidence / 10), 0.20);
		}

		create water {
			location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
		}

		create traffic_light from: node_shp {
			color_fire <- flip(0.5) ? #red : #green;
			nbred <- 30 + rnd(70);
			nbgreen <- 15 + rnd(40);
		}

		ask (length(traffic_light) * 0.9) among traffic_light {
			do die;
		}

		create road from: road_shp {
		}

		active_cells <- pollutant_grid where (!empty(road overlapping each));
		ask active_cells {
			active <- true;
		}

		road_weights <- road as_map (each::each.shape.perimeter);
		road_geom <- union(road accumulate (each.shape));
		road_graph <- as_edge_graph(list(road));
		create building from: building_shp {
			depth <- (10 + (rnd(20)) / 150 * shape.perimeter);
			texture <- textures[rnd(9)];
		}

		create vehicle number: nbvehicle {
			type <- TYPE_MOTORBIKE;
			location <- any_location_in(road_geom);
		}

	}

	user_command "Create a vehicle" {
		if (!edit_mode) {
			return;
		}

		create vehicle number: 1 {
			type <- TYPE_MOTORBIKE;
			location <- mouse_target;
		} }

	user_command "Create a traffic light" {
		if (!edit_mode) {
			return;
		}

		create traffic_light number: 1 with: (location: mouse_target) {
			color_fire <- flip(0.5) ? #red : #green;
			nbred <- 30 + rnd(70);
			nbgreen <- 15 + rnd(40);
		} }

	user_command "Create a building" {
		if (!edit_mode) {
			return;
		}

		map answers <- user_input("Amount", ["Amount"::1]);
		int num <- int(answers["Amount"]);
		create building number: num {
			osm_name <- "osm_agent" + self;
			shape <- any(building);
			location <- any_location_in(circle(num * 2) at_location mouse_target);
			depth <- (10 + (rnd(20)) / 150 * shape.perimeter);
			texture <- textures[rnd(9)];
		}

	}

	user_command "Enter edit mode" {
		edit_mode <- true;
	}

	user_command "Exit edit mode" {
		edit_mode <- false;
	}

	list<agent> get_all_instances (species<agent> spec) {
		return spec.population + spec.subspecies accumulate (get_all_instances(each));
	}

	action click {
		mouse_target <- #user_location;
		if (!edit_mode) {
			return;
		}

		if (empty(moved_agents)) {
			list<moveable> selected_agents <- list<moveable>(get_all_instances(moveable) overlapping (zone at_location #user_location));
			moved_agents <- selected_agents;
			ask selected_agents {
				difference <- #user_location - location;
				color <- #olive;
			}

		} else if (can_drop) {
			ask moved_agents {
				color <- #burlywood;
			}

			moved_agents <- list<moveable>([]);
		}

	}

	action move {
		if (!edit_mode) {
			return;
		}

		can_drop <- true;
//		mouse_target <- #user_location;
		ask moved_agents {
			location <- #user_location - difference;
		}

	} }

experiment show_example type: gui {  
	output {
		display subsidence background: #black type: opengl {
			overlay position: {4, 3} size: {180 #px, 20 #px} background: #black transparency: 0.1 border: #black rounded: true {
				if (edit_mode) {
					draw "Editing" at: {20 #px, 10 #px} color: #white border: #black;
				}

			}


			species traffic_light;
			species road refresh: false; // position: {0, 0, 0.002};
			species building;
			species vehicle; //position: {0, 0, 0.002};
			grid DEMcell elevation: subsidence position: {0, 0, -0.004} transparency: 0.0 triangulation: true;
			species water transparency: 0.9;
			//			grid pollutant_grid elevation: pollution / 10 < 0 ? 0.0 : pollution / 10 transparency: 0.4 triangulation: true;
			event mouse_move action: move;
			event mouse_up action: click;
		}

		display polution background: #black type: opengl {
			overlay position: {4, 3} size: {180 #px, 20 #px} background: #black transparency: 0.1 border: #black rounded: true {
				if (edit_mode) {
					draw "Editing" at: {20 #px, 10 #px} color: #white border: #black;
				}

			}

			species traffic_light;
			species road refresh: false; // position: {0, 0, 0.002};
			species building;
			species vehicle; //position: {0, 0, 0.002};
			grid pollutant_grid elevation: pollution / 10 < 0 ? 0.0 : pollution / 10 transparency: 0.4 triangulation: true;
			event mouse_move action: move;
			event mouse_up action: click;
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
