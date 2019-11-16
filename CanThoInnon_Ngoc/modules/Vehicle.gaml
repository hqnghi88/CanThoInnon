model Vehicle

import "Moveable.gaml"
import "TrafficLight.gaml"
import "GlobalVariable.gaml"
import "../modules/Water.gaml"
import "../modules/DEMCell.gaml"
species vehicle skills: [moving] parent: moveable {
	rgb color;
	string type;
	int nb_people;
	bool go_work <- true;
	string carburant <- "essence";
	float wsize <- (14.0 + rnd(1)) * 1;
	float hsize <- (6.0 + rnd(2)) * 1;
	float depth <- (4.0 + rnd(2)) * 1;
	bool insane <- flip(0.00001) ? true : false;
	float speed <- ((insane ? 20 + rnd(20) : 10 + rnd(10.0)) °m / °h) *1;
	float csp <- speed;
	float perception_distance <- wsize * 1.5; //view size must be 1.5 times of my size
	geometry shape <- box(wsize, hsize, depth);
	geometry TL_area;
	point target <- nil;
	rgb csd <- #green;
	bool waiting_traffic_light <- false;
	int time_on_road <- 0;
	float get_pollution {
	//		write  csp * coeff_vehicle[type];
		return csp * coeff_vehicle[type] * wsize * hsize*1.2;
	}

	reflex move when: target != nil {
		time_on_road <- time_on_road + 1;
		if(!waiting_traffic_light){			
			do goto target: target on: road_graph recompute_path: recompute_path speed: csp move_weights: road_weights;
		}
		if (target != nil and location distance_to target <= speed) {
		//		if (target = location){
			target <- nil;
			time_on_road <- 0;
			return;
		}

		//		TL_area <- (cone(heading - 15, heading + 15) intersection world.shape) intersection (circle(perception_distance));
		TL_area <- ((cone(heading - 10, heading + 10) intersection world.shape) intersection (circle(perception_distance)) - shape);
		list<vehicle> v <- (((vehicle - self) at_distance (perception_distance))) where (each overlaps TL_area); //!(each.TL_area overlaps TL_area) and each.current_edge = self.current_edge and
		list<traffic_light> redlight <- (((traffic_light) at_distance (perception_distance*2)) where (each.color_fire = #red)) overlapping TL_area;
		//		list<vehicle> v <- (vehicle at_distance (perception_distance)) where (!(each.TL_area overlaps TL_area) and (each overlaps TL_area));
		waiting_traffic_light <- false;
		if (length(redlight) > 0  or (length(v where (each.current_edge = current_edge and each.waiting_traffic_light)) > 0)) {
			waiting_traffic_light <- true;
			return;
		}
 

		if (length(v) > 0) {
//			csd <- #darkred;
			if (csp = speed) {
				csp <- (v min_of each.csp);
			}

		} else {
			csd <- #green;
			csp <- speed;
		}

		if ((first(water).wlevel > -13.30) and length(DEMcell overlapping self) > 0) {
			if ((first(DEMcell overlapping self).subsidence < 30)) {
				csd <- #black + 50;
				csp <- (rnd(5) °m / °h);
			} else {
				csd <- #green;
				csp <- speed;
			}

		}

	}

	reflex choose_target when: target = nil {
	//		target <- any_location_in(road_geom);
		if (go_work) {
			go_work <- false;
			target <- any_location_in(road_geom);
		} else {
			go_work <- true;
			target <- any_location_in(any(building where (each.osm_name index_of "osm_agent" != 0)));
		}

	}

	aspect default {
		draw shape color: csd rotate: heading;
	}

	aspect texture {
	//		draw box(wsize - 2, hsize, depth + 2) color: csd rotate: heading;
		if (csd = #green) {
			draw shape texture: [cartop, carside, carback, carfront] color: csd rotate: heading;
		} else {
			draw shape color: csd rotate: heading;
		}

		if (draw_perception and TL_area != nil) {
			draw TL_area color: csd empty: true depth: 0.5;
		}

	}

}
