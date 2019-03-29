/**
* Name: GeoTIFF file to Grid of Cells 
* Author:  Patrick Taillandier
* Description: Model which shows how to create a grid of cells by using a GeoTIFF File. 
* Tags:  load_file, tif, gis, grid
*/
model CanThoInno

global {
//definiton of the file to import
	file grid_data <- file('../includes/NKdem.tif');
	file road_shp <- file("../includes/ninhkieu.shp");
	file building_shp <- file("../includes/buildingNK.shp");
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(building_shp);
	file roof_texture <- file('../images/building_texture/roof_top.png');
	list textures <- [file('../images/building_texture/texture1.jpg'), file('../images/building_texture/texture2.jpg'), file('../images/building_texture/texture3.jpg'), file('../images/building_texture/texture4.jpg'), file('../images/building_texture/texture5.jpg'), file('../images/building_texture/texture6.jpg'), file('../images/building_texture/texture7.jpg'), file('../images/building_texture/texture8.jpg'), file('../images/building_texture/texture9.jpg'), file('../images/building_texture/texture10.jpg')];
	graph road_graph;
	float max_value;
	float min_value;
	bool show_building_names<-false;
	bool recompute_path <- false;
	geometry road_geom;
	map<road,float> road_weights;

	init {
	//		ask cell {
	//			grid_value <- grid_value + 33;
	//		}
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		write max_value;
		write min_value;
		ask cell {
		//			grid_value <- grid_value;
		//			float val <- (1 - (grid_value - min_value) / ((max_value - min_value) + 10));
		//			color <- hsb(35 / 360, val * val, 0.64);
			float val <- (1 - (grid_value - min_value) / (max_value - min_value));
			color <- hsb(222 / 360, val,0.9);
			//			color<-rgb(0,0,val*255);
		}

						create water {
							location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
						}
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
			depth <-   (rnd(100) / 100 * shape.width) ;
			texture <- textures[rnd(9)];
		}

		create vehicle number: 1500 {
			location <- any_location_in(road_geom);
			//			location <- any_location_in(any(road));
			//			target <- any_location_in(any(road));
		}

	}

}

species vehicle skills: [moving] {
	rgb color;
	string type;
	int nb_people;
	float wsize <- 5.0 + rnd(2);
	float hsize <- 2.0 + rnd(2);
	bool insane<-flip(0.001)?true:false;
	float sp <- insane?70+rnd(50):10 + rnd(30.0);
	float csp <- sp;
	//	float ccsp <- csp;
	float perception_distance <- wsize * 2;
	geometry shape <- rectangle(wsize, hsize);
	geometry TL_area;
	point target <- nil;
	rgb csd <- #green;

	reflex move when: target != nil {
		do goto target: target on: road_graph recompute_path: recompute_path speed: csp move_weights: road_weights;
		if (target != nil and location distance_to target <= sp) {
		//		if (target = location){
			target <- nil;
		}

		TL_area <- (cone(heading - 5, heading + 5) intersection world.shape) intersection (circle(perception_distance));
		list v <- (vehicle at_distance (perception_distance)) overlapping TL_area;
		if (length(v) > 0) {
			csd <- #red;
			if (csp = sp) {
			//				if (csp = ccsp) {
			//					ccsp <- v min_of each.csp;
			//				}
				csp <- v min_of each.csp;
			}

			//			if (ccsp > 6) {
			//				ccsp <- ccsp - 5;
			//			}

		} else {
		//			if(csp<sp){
			csd <- #green;
			csp <- sp;
			//			ccsp <- csp;
			//			}
		}

	}

	reflex choose_target when: target = nil {
		target <- any_location_in(road_geom);
		//		target <-any(building).location;
	}

	aspect default {
		draw shape color: csd border: #black depth: 1 rotate: heading;
//		if (TL_area != nil) {
//			draw TL_area color: csd depth: 0.5;
//		}

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

	aspect default {
		draw shape+3 color: #gray;
	}

}

species water {
	float wlevel <- -14.0;
	int incr <- 1;
	geometry shape <- box(world.shape.width, world.shape.height, 1);

	reflex innon {
		wlevel <- wlevel + incr * 0.05;
		if (wlevel > -9) {
			incr <- -1;
		}

		if (wlevel < -14.0) {
			incr <- 1;
		}

		location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
	}

	aspect default {
		draw shape color: #blue at: location;
	}

}

species building {
	float depth;
	string osm_name;
	file texture;
	reflex gravity{
		cell c<-cell at location; 
		if(c!=nil){			
			c.grid_value<-c.grid_value-shape.perimeter/100;
		}
	}
	aspect default {
		draw shape depth: depth texture: [roof_texture.path, texture.path] color: rnd_color(255);
		if(show_building_names and osm_name index_of "osm_agent" != 0){
//			write osm_name;
			draw  osm_name size:0.010  color:#yellow at:{location.x,location.y, (depth+1)} perspective:false ;
		}
	}

}
//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
grid cell file: grid_data{ 
}

experiment show_example type: gui {
	parameter "Show Building Name" var:show_building_names;
	output {
		display test camera_pos: {956.6999,3239.5736,511.4931} camera_look_pos: {1799.5599,1836.819,-322.3095} camera_up_vector: {0.2338,0.3891,0.891} 
		type: opengl 
		{
			species water;
//						grid cell refresh: false;
			species road refresh: false; // position: {0, 0, 0.002};
			species building refresh: false;
			species vehicle; //position: {0, 0, 0.002};
			grid cell elevation: grid_value triangulation: true refresh: true position: {0, 0, -0.003}; // transparency: 0.0
		}

//				display FirstPerson type: opengl camera_interaction: false camera_pos: {int(first(vehicle).location.x), int(first(vehicle).location.y), 5.0} camera_look_pos:
//				{cos(first(vehicle).heading) * first(vehicle).speed + int(first(vehicle).location.x), sin(first(vehicle).heading) * first(vehicle).speed + int(first(vehicle).location.y), 5.0}
//				camera_up_vector: {0.0, 0.0, -1.0} {
//				//			grid cell elevation: grid_value triangulation: true refresh: false;
//					grid cell refresh: false;
//					species road refresh: false;
//					species building refresh: false;
//					species vehicle;
//				}

	}

}
