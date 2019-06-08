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
import "../modules/Actions.gaml"

global {
//definiton of the file to import
	float step <- 1 #hour;

	init {
		ask DEMcell {
			subsidence <- subsidence + grid_value;
		}

		ask DEMcell {
			color <- hsb(0 / 360, 0, 1 - ((subsidence + maxsub) / (maxsub * 4)));
			//			color <- hsb(210 / 360, subsidence / 10 > 1 ? 1 : (subsidence / 10 < 0 ? 0 : subsidence / 10), 0.20);
		}

		create water {
			location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
		}

		//		write node_shp as list;
		create traffic_light from: node_shp {
			color_fire <- flip(0.5) ? #red : #green;
			nbred <- 30 + rnd(20);
			nbgreen <- 15 + rnd(20);
		}
		//		 	save traffic_light to:"../includes/nkNodesSimple2.shp" type:"shp";
		create road from: road_shp {
		}
		//			save road to:"../includes/nkRoadsSimple3.shp" type:"shp";
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

	reflex ss {
	//	write max(pollutant_grid collect each.pollution);
	}

}

experiment show_example type: gui autorun: true {

	init {
		gama.pref_display_show_referential <- false;
		gama.pref_display_show_rotation <- false;
	}

	output {
		layout #stack navigator: false editors: false consoles: false tray: false toolbars: false tabs: true;
		display "Statistic" {
			chart "Number of critical pollution" type: series {
				data "pollution " value: length(pollutant_grid where (each.pollution > 0.01)) color: #red marker: false style: line;
			}

		}

		display "Statistic2" {
			chart "Average time on road" type: series {
				data "time " value: median(vehicle collect (each.time_on_road)) color: #red marker: false style: line;
			}

		}

		display "Edit Map" type: opengl {
			overlay position: {4, 3} size: {100 #px, 30 #px} background: #black transparency: 0.1 border: #black rounded: true {
				if (edit_mode) {
					draw "Editing" font: regular at: {20 #px, 20 #px} color: #black border: #white;
				}

			}

			species traffic_light;
			species road refresh: false; // position: {0, 0, 0.002};
			species building;
			species vehicle; //position: {0, 0, 0.002}; 
			event mouse_move action: move;
			event mouse_up action: click;
		}

		display "Simulation result" type: opengl camera_pos: {775.7492,1781.1727,386.618} camera_look_pos: {775.7492,943.9393,-199.5973} camera_up_vector: {0.0,0.5736,0.8192} {
			species traffic_light;
			species road refresh: false transparency: 0.51; // position: {0, 0, 0.002};
			species building aspect: texture;
			species vehicle aspect: texture;
			grid DEMcell texture: terrain elevation: subsidence / 10 position: {0, 0, -0.0085} triangulation: true;
			species water transparency: 0.59;
			grid pollutant_grid elevation: (pollution * (10)) < 0 ? 0.0 : (pollution * (10)) transparency: 0.79 triangulation: true;
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
