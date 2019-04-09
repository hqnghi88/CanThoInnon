model Vehicle
import "Moveable.gaml"
import "TrafficLight.gaml"
import "GlobalVariable.gaml"
species vehicle skills: [moving] parent: moveable {
	rgb color;
	string type;
	int nb_people;
	string carburant <- "essence";
	float wsize <- 5.0 + rnd(4);
	float hsize <- 2.0 + rnd(4);
	bool insane <- flip(0.0001) ? true : false;
	float speed <- (insane ? 70 + rnd(50) : 10 + rnd(60.0)) °km / °h;
	float csp <- speed;
	float perception_distance <- wsize * 4;
	geometry shape <- rectangle(wsize, hsize);
	geometry TL_area;
	point target <- nil;
	rgb csd <- #green;
	bool waiting_traffic_light <- false;
	float pollution_from_speed {
		float returnedValue <- -1.0;
		loop spee over: pollution_rate[carburant].keys {
			if (real_speed < spee) {
				returnedValue <- pollution_rate[carburant][spee];
				break;
			}

		}

		return (returnedValue != -1.0) ? returnedValue : pollution_rate[carburant][last(pollution_rate[carburant].keys)];
	}

	float get_pollution {
		return pollution_from_speed() * coeff_vehicle[type];
	}

	reflex move when: target != nil {
		TL_area <- (cone(heading - 15, heading + 15) intersection world.shape) intersection (circle(perception_distance));
		list<traffic_light> redlight <- (((traffic_light) at_distance perception_distance) where (each.color_fire = #red)) overlapping TL_area;
		list<vehicle> v <- (vehicle at_distance (perception_distance)) where (!(each.TL_area overlaps TL_area) and (each overlaps TL_area));
		if (length(redlight) > 0) {
			waiting_traffic_light <- true;
			return;
		}

		if (!waiting_traffic_light and length(v where (each.waiting_traffic_light)) > 0) {
			waiting_traffic_light <- true;
			return;
		}

		waiting_traffic_light <- false;
		if (length(v) > 0) {
			csd <- #darkgreen;
			if (csp = speed) {
				csp <- (v min_of each.csp);
			}

		} else {
			csd <- #green;
			csp <- speed;
		}

		do goto target: target on: road_graph recompute_path: recompute_path speed: csp move_weights: road_weights;
		if (target != nil and location distance_to target <= speed) {
		//		if (target = location){
			target <- nil;
		}

	}

	reflex choose_target when: target = nil {
		target <- any_location_in(road_geom);
	}

	aspect default {
		draw shape color: csd border: #black depth: 1 rotate: heading;
		if (draw_perception and TL_area != nil) {
			draw TL_area color: csd empty: true depth: 0.5;
		}

	}

}
