model GlobalVariable

import "Moveable.gaml"
import "Road.gaml"
import "PollutantGrid.gaml"

global {
	file grid_data <- file('../includes/nkdemsimple3.tif');
	file road_shp <- file("../includes/nkRoadsSimple3.shp");
	file node_shp <- file("../includes/nkNodesSimple2.shp");
	file building_shp <- file("../includes/nkBuildingSimple2.shp");
	geometry shape <- envelope(road_shp);
	file roof_texture <- file('../images/building_texture/roof_top.png');
	list
	textures <- [file('../images/building_texture/texture1.jpg'), file('../images/building_texture/texture2.jpg'), file('../images/building_texture/texture3.jpg'), file('../images/building_texture/texture4.jpg'), file('../images/building_texture/texture5.jpg'), file('../images/building_texture/texture6.jpg'), file('../images/building_texture/texture7.jpg'), file('../images/building_texture/texture8.jpg'), file('../images/building_texture/texture9.jpg'), file('../images/building_texture/texture10.jpg')];
	graph road_graph;
	bool draw_perception <- false;
	float max_value;
	float min_value;
	bool recompute_path <- false;
	geometry road_geom;
	int nbvehicle <- 100;
	map<road, float> road_weights;
	list<moveable> moved_agents;
	point mouse_target;
	geometry zone <- circle(5);
	bool can_drop;
	bool edit_mode <- true;
	string TYPE_MOTORBIKE <- "motorbyke";
	string TYPE_CAR <- "car";
	string TYPE_TRUCK <- "truck";
	float MOTORBIKE_COEF <- 1.0;
	float CAR_COEF <- 2.0;
	float TRUCK_COEF <- 2.0;
	map<string, float> coeff_vehicle <- map([TYPE_MOTORBIKE::MOTORBIKE_COEF, TYPE_CAR::CAR_COEF, TYPE_TRUCK::TRUCK_COEF]);
	float coeff_building <- 1.0;
	list<pollutant_grid> active_cells;
	float decrease_coeff <- 0.5;
	//	map<string, map<int, float>>
	//	pollution_rate <- ["essence"::[10::98.19, 20::69.17, 30::56.32, 40::49.3, 50::45.29], "diesel"::[10::201.74, 20::152, 30::127.82, 40::114.29, 50::106.48]];
	font regular <- font("Arial", 20, #bold);
	float maxsub <- 147.0;

	image_file terrain <- image_file("../images/terrain1.png");
	image_file cartxt <- image_file("../images/car1.png");
	image_file cartop <- image_file("../images/cartop.jpg");
	image_file carside <- image_file("../images/carside.jpg");
	image_file carfront <- image_file("../images/carfront.jpg");
	image_file carback <- image_file("../images/carback.jpg");
	//	geometry motor3d<-geometry(obj_file("../motor/Bike.obj"));
}



