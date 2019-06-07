model DEMCell
import "Building.gaml"
grid DEMcell file: grid_data neighbors: 8 {
	rgb color <- #black;
	bool active <- true;
	float subsidence <- 1.0;

	reflex pollution_increase when: active {
		list<building> building_on_cell <- building overlapping self;
		subsidence <- subsidence < 0 ? 0 : subsidence - (sum(building_on_cell accumulate (each.get_weight())) * 0.1);
	}

	reflex diffusion {
		ask neighbors {
			subsidence <- subsidence < 0 ? 0 : subsidence - 0.0005 * myself.subsidence;
		}

	}

	reflex update {
		color <- hsb(210 / 360, subsidence / 10 > 1 ? 1 : (subsidence / 10 < 0 ? 0 : subsidence / 10), 0.40);
	}

}

